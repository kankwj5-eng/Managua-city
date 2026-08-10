using UnityEngine;
using System.Collections;

public class EnemyAI : MonoBehaviour
{
    public enum EnemyState { Patrolling, Chasing, Shooting, SeekingCover, Dead }
    public EnemyState currentState = EnemyState.Patrolling;

    [Header("Health & Stats")]
    public float maxHealth = 60f;
    public float currentHealth = 60f;
    public float moveSpeed = 3f;
    public float chaseSpeed = 5f;

    [Header("Sensing & Combat")]
    public float detectionRadius = 15f;
    public float shootingRadius = 8f;
    public float bulletDamage = 10f;
    public float fireRate = 1f;

    [Header("Patrol Settings")]
    public Transform[] patrolWaypoints;
    public float waypointTolerance = 1f;

    private int currentWaypointIndex = 0;
    private float nextTimeToFire = 0f;
    private Transform playerTransform;
    private PlayerController playerController;

    void Start()
    {
        currentHealth = maxHealth;
        GameObject playerObj = GameObject.FindWithTag("Player");
        if (playerObj != null)
        {
            playerTransform = playerObj.transform;
            playerController = playerObj.GetComponent<PlayerController>();
        }
    }

    void Update()
    {
        if (currentState == EnemyState.Dead) return;

        UpdateAIBehavior();
    }

    void UpdateAIBehavior()
    {
        if (playerTransform == null) return;

        float distanceToPlayer = Vector3.Distance(transform.position, playerTransform.position);
        bool playerInVehicle = playerController != null && playerController.IsInVehicle();

        switch (currentState)
        {
            case EnemyState.Patrolling:
                Patrol();
                // Transition to Chasing if player detected (and not hidden in vehicle or within radius)
                if (distanceToPlayer < detectionRadius && !playerInVehicle)
                {
                    currentState = EnemyState.Chasing;
                }
                break;

            case EnemyState.Chasing:
                Chase();
                if (distanceToPlayer < shootingRadius)
                {
                    currentState = EnemyState.Shooting;
                }
                else if (distanceToPlayer > detectionRadius || playerInVehicle)
                {
                    currentState = EnemyState.Patrolling;
                }
                break;

            case EnemyState.Shooting:
                ShootAtPlayer();
                if (distanceToPlayer > shootingRadius)
                {
                    currentState = EnemyState.Chasing;
                }
                if (currentHealth < (maxHealth * 0.3f)) // Under 30% health -> seek cover
                {
                    currentState = EnemyState.SeekingCover;
                }
                break;

            case EnemyState.SeekingCover:
                SeekCover();
                break;
        }
    }

    void Patrol()
    {
        if (patrolWaypoints == null || patrolWaypoints.Length == 0) return;

        Transform targetWaypoint = patrolWaypoints[currentWaypointIndex];
        Vector3 direction = (targetWaypoint.position - transform.position).normalized;
        direction.y = 0;

        transform.position += direction * moveSpeed * Time.deltaTime;

        if (direction.magnitude > 0.1f)
        {
            transform.rotation = Quaternion.Slerp(transform.rotation, Quaternion.LookRotation(direction), 8f * Time.deltaTime);
        }

        if (Vector3.Distance(transform.position, targetWaypoint.position) < waypointTolerance)
        {
            currentWaypointIndex = (currentWaypointIndex + 1) % patrolWaypoints.Length;
        }
    }

    void Chase()
    {
        if (playerTransform == null) return;

        Vector3 direction = (playerTransform.position - transform.position).normalized;
        direction.y = 0;

        transform.position += direction * chaseSpeed * Time.deltaTime;
        transform.rotation = Quaternion.Slerp(transform.rotation, Quaternion.LookRotation(direction), 10f * Time.deltaTime);
    }

    void ShootAtPlayer()
    {
        if (playerTransform == null) return;

        // Rotate to look at player
        Vector3 direction = (playerTransform.position - transform.position).normalized;
        direction.y = 0;
        transform.rotation = Quaternion.Slerp(transform.rotation, Quaternion.LookRotation(direction), 12f * Time.deltaTime);

        // Limit rate of fire
        if (Time.time >= nextTimeToFire)
        {
            nextTimeToFire = Time.time + fireRate;

            // Check line of sight
            RaycastHit hit;
            if (Physics.Raycast(transform.position + Vector3.up, direction, out hit, shootingRadius))
            {
                if (hit.collider.CompareTag("Player"))
                {
                    Debug.Log(name + " has shot the player!");
                    if (playerController != null)
                    {
                        playerController.TakeDamage(bulletDamage);
                    }
                }
            }
        }
    }

    void SeekCover()
    {
        // GTA Cover logic: find closest obstacle (tagged Cover or Static) and hide behind it relative to player.
        GameObject[] coverObjects = GameObject.FindGameObjectsWithTag("Cover");
        if (coverObjects == null || coverObjects.Length == 0)
        {
            // Fallback: retreat from player
            currentState = EnemyState.Chasing;
            return;
        }

        GameObject closestCover = null;
        float minDist = Mathf.Infinity;
        foreach (GameObject cover in coverObjects)
        {
            float dist = Vector3.Distance(transform.position, cover.transform.position);
            if (dist < minDist)
            {
                minDist = dist;
                closestCover = cover;
            }
        }

        if (closestCover != null)
        {
            // Position self behind the cover relative to player
            Vector3 coverDirection = (closestCover.transform.position - playerTransform.position).normalized;
            Vector3 coverDestination = closestCover.transform.position + coverDirection * 1.5f;

            Vector3 direction = (coverDestination - transform.position).normalized;
            direction.y = 0;
            transform.position += direction * chaseSpeed * Time.deltaTime;
            transform.rotation = Quaternion.Slerp(transform.rotation, Quaternion.LookRotation(direction), 10f * Time.deltaTime);

            if (Vector3.Distance(transform.position, coverDestination) < 1f)
            {
                // Regroup, wait a moment, and shoot again or recover health
                StartCoroutine(RecoverInCover());
            }
        }
    }

    IEnumerator RecoverInCover()
    {
        yield return new WaitForSeconds(3f);
        if (currentHealth < maxHealth)
        {
            currentHealth += 15f; // Recover small health in cover
        }
        currentState = EnemyState.Chasing; // back to fight
    }

    public void TakeDamage(float amount)
    {
        if (currentState == EnemyState.Dead) return;

        currentHealth -= amount;
        Debug.Log(name + " took " + amount + " damage! Current health: " + currentHealth);

        if (currentState == EnemyState.Patrolling)
        {
            // Instantly trigger combat state if attacked
            currentState = EnemyState.Chasing;
        }

        if (currentHealth <= 0f)
        {
            Die();
        }
    }

    void Die()
    {
        currentState = EnemyState.Dead;
        Debug.Log(name + " has died.");

        // Notify MissionManager if this enemy death affects a mission goal
        MissionManager mm = FindObjectOfType<MissionManager>();
        if (mm != null)
        {
            mm.OnEnemyKilled(this);
        }

        // Add Ragdoll, points, or loot drops here
        // Simple visual queue: drop or fall flat
        transform.Rotate(90f, 0, 0);
        GetComponent<Collider>().enabled = false;
        Destroy(gameObject, 5f);
    }
}
