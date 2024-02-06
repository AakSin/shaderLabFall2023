using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof (MeshFilter))]
[RequireComponent(typeof (MeshRenderer))]
public class ProceduralCube : MonoBehaviour
{
    Mesh mesh;

    void Start()
    {
        MakeCube();
    }

    void MakeCube() {
        // set up mesh data
        
        // vectors for the position of each vertex
        Vector3[] vertices = {
            new (0,0,0),
            new (1,0,0),
            new (1,1,0),
            new (0,1,0),
            new (0,1,1),
            new (1,1,1),
            new (1,0,1),
            new (0,0,1)
        };
        
        // create triangle array or index array
        // every three ints creates a triangle

        int[] triangles = {
            0, 3, 2, // south face
            0, 2, 1,
            3, 4, 5, // up face
            3, 5, 2,
            1, 2, 5, // east face
            1, 5, 6,
            0, 7, 4, // west face
            0, 4, 3,
            7, 6, 5, // north face
            7, 5, 4,
            0, 1, 6, // down face
            0, 6, 7
        };

        mesh = GetComponent<MeshFilter>().mesh;
        mesh.Clear();
        mesh.vertices = vertices;
        mesh.triangles = triangles;
    }

    void OnDestroy() {
        Destroy(mesh);
    }
}
