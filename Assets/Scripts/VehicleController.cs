using UnityEngine;

[RequireComponent(typeof(Rigidbody))]
public class VehicleController : MonoBehaviour
{
    [Header("Vehicle Physics Settings")]
    public float motorForce = 1500f;
    public float breakForce = 3000f;
    public float maxSteerAngle = 35f;

    [Header("Wheel Colliders (Physics)")]
    public WheelCollider frontLeftWheel;
    public WheelCollider frontRightWheel;
    public WheelCollider rearLeftWheel;
    public WheelCollider rearRightWheel;

    [Header("Wheel Visuals (Mesh Transforms)")]
    public Transform frontLeftTransform;
    public Transform frontRightTransform;
    public Transform rearLeftTransform;
    public Transform rearRightTransform;

    [Header("GTA Driver System")]
    public Transform exitPoint;
    public Transform driverSeatPoint;
    public bool isBeingDriven = false;

    [Header("Visual Effects & Sound")]
    public GameObject headLights;
    public AudioSource engineSound;

    private float horizontalInput;
    private float verticalInput;
    private float currentSteerAngle;
    private float currentbreakForce;
    private bool isBreaking;

    private Rigidbody rb;

    void Start()
    {
        rb = GetComponent<Rigidbody>();
        rb.centerOfMass = new Vector3(0, -0.5f, 0); // lower center of mass for stability

        if (engineSound != null)
        {
            engineSound.loop = true;
            engineSound.Stop();
        }

        if (headLights != null)
        {
            headLights.SetActive(false);
        }
    }

    void Update()
    {
        if (!isBeingDriven)
        {
            // If nobody is driving, decelerate gradually
            ApplyIdleDeceleration();
            return;
        }

        GetInput();
    }

    void FixedUpdate()
    {
        if (!isBeingDriven) return;

        HandleMotor();
        HandleSteering();
        UpdateWheels();
    }

    private void GetInput()
    {
        horizontalInput = Input.GetAxis("Horizontal");
        verticalInput = Input.GetAxis("Vertical");
        isBreaking = Input.GetKey(KeyCode.Space);

        // Turn on headlights at night or manually
        if (Input.GetKeyDown(KeyCode.L) && headLights != null)
        {
            headLights.SetActive(!headLights.activeSelf);
        }
    }

    private void HandleMotor()
    {
        frontLeftWheel.motorTorque = verticalInput * motorForce;
        frontRightWheel.motorTorque = verticalInput * motorForce;

        currentbreakForce = isBreaking ? breakForce : 0f;
        ApplyBraking();
    }

    private void ApplyBraking()
    {
        frontLeftWheel.brakeTorque = currentbreakForce;
        frontRightWheel.brakeTorque = currentbreakForce;
        rearLeftWheel.brakeTorque = currentbreakForce;
        rearRightWheel.brakeTorque = currentbreakForce;
    }

    private void ApplyIdleDeceleration()
    {
        // Smoothly roll to stop if not controlled
        frontLeftWheel.motorTorque = 0f;
        frontRightWheel.motorTorque = 0f;
        frontLeftWheel.brakeTorque = 100f;
        frontRightWheel.brakeTorque = 100f;
        rearLeftWheel.brakeTorque = 100f;
        rearRightWheel.brakeTorque = 100f;
    }

    private void HandleSteering()
    {
        currentSteerAngle = horizontalInput * maxSteerAngle;
        frontLeftWheel.steerAngle = currentSteerAngle;
        frontRightWheel.steerAngle = currentSteerAngle;
    }

    private void UpdateWheels()
    {
        UpdateSingleWheel(frontLeftWheel, frontLeftTransform);
        UpdateSingleWheel(frontRightWheel, frontRightTransform);
        UpdateSingleWheel(rearLeftWheel, rearLeftTransform);
        UpdateSingleWheel(rearRightWheel, rearRightTransform);
    }

    private void UpdateSingleWheel(WheelCollider wheelCollider, Transform wheelTransform)
    {
        if (wheelTransform == null) return;

        Vector3 pos;
        Quaternion rot;
        wheelCollider.GetWorldPose(out pos, out rot);
        wheelTransform.position = pos;
        wheelTransform.rotation = rot;
    }

    public void OnPlayerEnter()
    {
        isBeingDriven = true;
        if (engineSound != null)
        {
            engineSound.Play();
        }
        if (headLights != null)
        {
            headLights.SetActive(true);
        }
    }

    public void OnPlayerExit()
    {
        isBeingDriven = false;
        horizontalInput = 0f;
        verticalInput = 0f;
        isBreaking = true;
        ApplyBraking();

        if (engineSound != null)
        {
            engineSound.Stop();
        }
        if (headLights != null)
        {
            headLights.SetActive(false);
        }
    }
}
