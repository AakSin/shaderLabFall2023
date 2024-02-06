using UnityEngine;

[ExecuteInEditMode, ImageEffectAllowedInSceneView]
public class CaveMaster : MonoBehaviour {

    public ComputeShader caveShader;
    public float movementSpeed;
    RenderTexture target;
    Camera cam;
    Light directionalLight;

    void Start() {
        Application.targetFrameRate = 60;
    }
    
    void Init () {
        cam = Camera.current;
        directionalLight = FindObjectOfType<Light> ();
    }

    // Animate properties
    void Update () {

        if (Application.isPlaying) {
            transform.position += transform.forward * Time.deltaTime * movementSpeed;
            // directionalLight.transform.Rotate(50*Time.deltaTime,80*Time.deltaTime,0);
            directionalLight.transform.eulerAngles = -transform.eulerAngles;

        }   
             
    }

    void OnRenderImage (RenderTexture source, RenderTexture destination) {
        Init ();
        InitRenderTexture ();
        SetParameters ();

        int threadGroupsX = Mathf.CeilToInt (cam.pixelWidth / 8.0f);
        int threadGroupsY = Mathf.CeilToInt (cam.pixelHeight / 8.0f);
        caveShader.Dispatch (0, threadGroupsX, threadGroupsY, 1);

        Graphics.Blit (target, destination);
    }

    void SetParameters () {
        caveShader.SetTexture (0, "Destination", target);
        caveShader.SetVector("_CameraPos",transform.position);
        caveShader.SetVector ("_Time", Shader.GetGlobalVector ("_Time"));

        caveShader.SetMatrix ("_CameraToWorld", cam.cameraToWorldMatrix);
        caveShader.SetMatrix ("_CameraInverseProjection", cam.projectionMatrix.inverse);
        caveShader.SetVector ("_LightDirection", directionalLight.transform.forward);

    }

    void InitRenderTexture () {
        if (target == null || target.width != cam.pixelWidth || target.height != cam.pixelHeight) {
            if (target != null) {
                target.Release ();
            }
            target = new RenderTexture (cam.pixelWidth, cam.pixelHeight, 0, RenderTextureFormat.ARGBFloat, RenderTextureReadWrite.Linear);
            target.enableRandomWrite = true;
            target.Create ();
        }
    }
}