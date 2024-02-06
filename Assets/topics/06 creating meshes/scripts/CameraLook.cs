using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraLook : MonoBehaviour
{
    // Start is called before the first frame update
    // public GameObject target;
    Vector3 forward = new Vector3(0f, -0.1f, 0.0f);
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        // transform.LookAt(target.transform);
        transform.position += forward * Time.deltaTime;
    }
}
