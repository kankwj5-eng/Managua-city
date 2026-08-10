using UnityEngine;

public class PlayerController : MonoBehaviour
{
    public float moveSpeed = 5f;
    public float rotationSpeed = 5f;
    private CharacterController charController;
    private Vector3 moveDirection;

    void Start()
    {
        charController = GetComponent<CharacterController>();
    }

    void Update()
    {
        HandleInput();
        ApplyMovement();
    }

    void HandleInput()
    {
        float horizontal = Input.GetAxis("Horizontal");
        float vertical = Input.GetAxis("Vertical");

        moveDirection = new Vector3(horizontal, 0, vertical).normalized;

        if (moveDirection.magnitude > 0)
        {
            float targetAngle = Mathf.Atan2(moveDirection.x, moveDirection.z) * Mathf.Rad2Deg;
            transform.rotation = Quaternion.Lerp(
                transform.rotation,
                Quaternion.Euler(0, targetAngle, 0),
                rotationSpeed * Time.deltaTime
            );
        }
    }

    void ApplyMovement()
    {
        Vector3 movement = moveDirection * moveSpeed * Time.deltaTime;
        charController.Move(movement);

        // Gravedad
        movement.y -= 9.8f * Time.deltaTime;
    }
}
