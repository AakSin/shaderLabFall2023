using UnityEngine;

public class CameraController : MonoBehaviour
{
    public float movementSpeed = 2f; // Speed of camera movement
    public float rotationSpeed = 2f; // Speed of camera rotation
    public float verticalMovementSpeed = 3f; // Speed of vertical camera movement
    

    private void Update()
    {
        // Camera movement with WASD keys
        float horizontal = Input.GetAxis("Horizontal");
        float vertical = Input.GetAxis("Vertical");

        Vector3 movement = new Vector3(horizontal, 0f, vertical) * movementSpeed * Time.deltaTime;
        transform.Translate(movement);

        // Camera rotation when right mouse button is held down
        if (Input.GetMouseButton(0) || true)
        {
            float mouseX = Input.GetAxis("Mouse X");
            float mouseY = Input.GetAxis("Mouse Y");

            // Rotate the camera based on mouse input
            Vector3 rotation = new Vector3(-mouseY, mouseX, 0f) * rotationSpeed;
            transform.Rotate(rotation);
        }

        // Camera movement up and down with Q and E keys
        float upDownMovement = 0f;
        if (Input.GetKey(KeyCode.Q))
        {
            upDownMovement = -verticalMovementSpeed * Time.deltaTime;
        }
        else if (Input.GetKey(KeyCode.E))
        {
            upDownMovement = verticalMovementSpeed * Time.deltaTime;
        }

        
        Vector3 verticalMovement = transform.up * upDownMovement;
        transform.Translate(verticalMovement, Space.World);
    }
}