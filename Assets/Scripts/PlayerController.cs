using UnityEngine;
using System.Collections;

[RequireComponent(typeof(CharacterController))]
public class PlayerController : MonoBehaviour
{
    [Header("Movement Settings")]
    public float walkSpeed = 3f;
    public float runSpeed = 7f;
    public float gravity = 20.0f;
    public float jumpSpeed = 8.0f;
    public float rotationSpeed = 10f;

    [Header("Stats")]
    public float maxHealth = 100f;
    public float currentHealth = 100f;
    public float maxStamina = 100f;
    public float currentStamina = 100f;
    public float staminaDrainRate = 15f;
    public float staminaRegenRate = 10f;

    [Header("Camera & Aiming")]
    public Transform cameraTransform;
    public bool isAiming = false;

    // Component References
    private CharacterController charController;
    private WeaponSystem weaponSystem;

    // Movement state
    private Vector3 moveDirection = Vector3.zero;
    private bool isSprinting = false;
    private bool isGrounded = false;

    // Vehicle state
    private bool isInVehicle = false;
    private VehicleController currentVehicle;
    private Transform currentVehicleExitPoint;

    void Start()
    {
        charController = GetComponent<CharacterController>();
        weaponSystem = GetComponent<WeaponSystem>();

        if (cameraTransform == null && Camera.main != null)
        {
            cameraTransform = Camera.main.transform;
        }

        currentHealth = maxHealth;
        currentStamina = maxStamina;
    }

    void Update()
    {
        if (isInVehicle)
        {
            // If inside a vehicle, PlayerController update is suspended or handles exiting.
            HandleVehicleExitInput();
            return;
        }

        HandleInput();
        HandleStamina();
        ApplyMovement();
    }

    void HandleInput()
    {
        // Sprinting
        if (Input.GetKey(KeyCode.LeftShift) && currentStamina > 5f && Input.GetAxis("Vertical") > 0.1f && !isAiming)
        {
            isSprinting = true;
        }
        else
        {
            isSprinting = false;
        }

        // Aiming (GTA Style)
        isAiming = Input.GetButton("Fire2") || Input.GetKey(KeyCode.Mouse1);

        // Shooting
        if (isAiming && (Input.GetButtonDown("Fire1") || Input.GetKeyDown(KeyCode.Mouse0)))
        {
            if (weaponSystem != null)
            {
                weaponSystem.Shoot();
            }
        }

        // Reload
        if (Input.GetKeyDown(KeyCode.R))
        {
            if (weaponSystem != null)
            {
                weaponSystem.Reload();
            }
        }

        // Weapon switching (1, 2, 3)
        if (Input.GetKeyDown(KeyCode.Alpha1)) weaponSystem?.SwitchWeapon(0);
        if (Input.GetKeyDown(KeyCode.Alpha2)) weaponSystem?.SwitchWeapon(1);
        if (Input.GetKeyDown(KeyCode.Alpha3)) weaponSystem?.SwitchWeapon(2);

        // Interaction (E key)
        if (Input.GetKeyDown(KeyCode.E))
        {
            TryInteract();
        }
    }

    void HandleStamina()
    {
        if (isSprinting && charController.velocity.magnitude > 0.5f)
        {
            currentStamina -= staminaDrainRate * Time.deltaTime;
            if (currentStamina < 0f)
            {
                currentStamina = 0f;
                isSprinting = false;
            }
        }
        else
        {
            if (currentStamina < maxStamina)
            {
                currentStamina += staminaRegenRate * Time.deltaTime;
                if (currentStamina > maxStamina)
                {
                    currentStamina = maxStamina;
                }
            }
        }
    }

    void ApplyMovement()
    {
        isGrounded = charController.isGrounded;

        float horizontal = Input.GetAxis("Horizontal");
        float vertical = Input.GetAxis("Vertical");

        // Calculate direction based on main camera rotation (GTA alignment)
        Vector3 camForward = Vector3.zero;
        Vector3 camRight = Vector3.zero;

        if (cameraTransform != null)
        {
            camForward = cameraTransform.forward;
            camRight = cameraTransform.right;
            camForward.y = 0;
            camRight.y = 0;
            camForward.Normalize();
            camRight.Normalize();
        }
        else
        {
            camForward = Vector3.forward;
            camRight = Vector3.right;
        }

        Vector3 targetDirection = (camRight * horizontal + camForward * vertical).normalized;

        if (isGrounded)
        {
            float speed = isAiming ? walkSpeed * 0.5f : (isSprinting ? runSpeed : walkSpeed);
            moveDirection = targetDirection * speed;

            if (Input.GetButton("Jump") || Input.GetKey(KeyCode.Space))
            {
                moveDirection.y = jumpSpeed;
            }
        }

        // Apply gravity
        moveDirection.y -= gravity * Time.deltaTime;

        // Move character
        charController.Move(moveDirection * Time.deltaTime);

        // Rotation logic
        if (isAiming)
        {
            // Align player rotation with camera horizontal rotation when aiming
            if (cameraTransform != null)
            {
                Vector3 lookDir = cameraTransform.forward;
                lookDir.y = 0;
                if (lookDir.magnitude > 0.1f)
                {
                    Quaternion targetRot = Quaternion.LookRotation(lookDir);
                    transform.rotation = Quaternion.Slerp(transform.rotation, targetRot, rotationSpeed * Time.deltaTime);
                }
            }
        }
        else if (targetDirection.magnitude > 0.1f)
        {
            // Align player rotation to the movement direction when not aiming
            Quaternion targetRot = Quaternion.LookRotation(targetDirection);
            transform.rotation = Quaternion.Slerp(transform.rotation, targetRot, rotationSpeed * Time.deltaTime);
        }
    }

    void TryInteract()
    {
        // Try to interact with objects (Vehicles, Weapons, Clues, etc.)
        float interactRange = 3f;
        Collider[] colliders = Physics.OverlapSphere(transform.position, interactRange);

        foreach (Collider col in colliders)
        {
            Interactable interactable = col.GetComponent<Interactable>();
            if (interactable != null)
            {
                interactable.Interact(this);
                break;
            }
        }
    }

    void HandleVehicleExitInput()
    {
        if (Input.GetKeyDown(KeyCode.E))
        {
            ExitVehicle();
        }
    }

    public void EnterVehicle(VehicleController vehicle, Transform exitPoint)
    {
        isInVehicle = true;
        currentVehicle = vehicle;
        currentVehicleExitPoint = exitPoint;

        // Disable rendering and collision while inside the vehicle
        charController.enabled = false;
        GetComponent<Collider>().enabled = false;

        // Parent player to vehicle for translation
        transform.SetParent(vehicle.transform);
        transform.localPosition = Vector3.zero;
        transform.localRotation = Quaternion.identity;

        // Hide player mesh renderer models
        Renderer[] renderers = GetComponentsInChildren<Renderer>();
        foreach (Renderer rend in renderers)
        {
            rend.enabled = false;
        }
    }

    public void ExitVehicle()
    {
        if (currentVehicle == null) return;

        // Unparent and restore transform
        transform.SetParent(null);
        if (currentVehicleExitPoint != null)
        {
            transform.position = currentVehicleExitPoint.position;
            transform.rotation = currentVehicleExitPoint.rotation;
        }
        else
        {
            transform.position += Vector3.right * 2f; // Fallback exit
        }

        currentVehicle.OnPlayerExit();

        isInVehicle = false;
        currentVehicle = null;
        currentVehicleExitPoint = null;

        // Enable collision and character controller
        charController.enabled = true;
        GetComponent<Collider>().enabled = true;

        // Show player mesh renderers
        Renderer[] renderers = GetComponentsInChildren<Renderer>();
        foreach (Renderer rend in renderers)
        {
            rend.enabled = true;
        }
    }

    public void TakeDamage(float amount)
    {
        currentHealth -= amount;
        if (currentHealth <= 0f)
        {
            currentHealth = 0f;
            Die();
        }
    }

    public void Heal(float amount)
    {
        currentHealth += amount;
        if (currentHealth > maxHealth) currentHealth = maxHealth;
    }

    void Die()
    {
        Debug.Log("Lenner has fallen. Game Over.");
        // Find Game Manager and initiate restart
        GameManager gm = FindObjectOfType<GameManager>();
        if (gm != null)
        {
            gm.GameOver();
        }
    }

    public bool IsInVehicle()
    {
        return isInVehicle;
    }
}
