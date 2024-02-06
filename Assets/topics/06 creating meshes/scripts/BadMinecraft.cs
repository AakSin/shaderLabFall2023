using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof (MeshFilter))]
[RequireComponent(typeof (MeshRenderer))]
public class BadMinecraft : MonoBehaviour
{
    Mesh mesh;

    void Start()
    {
        MakeCube();
    }

    void MakeCube() {
        // defining each unique vertex position
        Vector3[] c = new Vector3[8];

        c[0] = new Vector3(0, 0, 0);
        c[1] = new Vector3(1, 0, 0);
        c[2] = new Vector3(1, 1, 0);
        c[3] = new Vector3(0, 1, 0);
        
        c[4] = new Vector3(0, 1, 1);
        c[5] = new Vector3(1, 1, 1);
        c[6] = new Vector3(1, 0, 1);
        c[7] = new Vector3(0, 0, 1);
        
        // define the vertices for our cube
        Vector3[] vertices = new Vector3[] { 
            // 0    1     2     3
            c[0], c[1], c[2], c[3], // south face
            
            // 4    5     6     7
            c[3], c[2], c[5], c[4], // up face
            
            // 8    9    10    11
            c[1], c[6], c[5], c[2], // east face
            
            //12   13    14    15
            c[0], c[3], c[4], c[7], // west face
            
            //16   17    18    19
            c[7], c[4], c[5], c[6], // north face
            
            //20   21    22    23
            c[0], c[1], c[6], c[7]  // down face
        };
        
        // define each unique normal direction
        Vector3 south = Vector3.back;
        Vector3 up = Vector3.up;
        Vector3 east = Vector3.right;
        Vector3 west = Vector3.left;
        Vector3 north = Vector3.forward;
        Vector3 down = Vector3.down;
        
        // define our normal array that we'll send to the mesh
        Vector3[] normals = new Vector3[] {
            south, south, south, south,
            up, up, up, up,
            east, east, east, east,
            west, west, west, west,
            north, north, north, north,
            down, down, down, down
        };
        
        
        // define the uv coordinates for our mesh
        Vector2[] uvs = new Vector2[] {
            // south
            new (0.0f, 0.0f), new (0.5f, 0.0f),
            new (0.5f, 0.5f), new (0.0f, 0.5f),
            
            // up
            new (0.0f, 0.5f), new (0.5f, 0.5f),
            new (0.5f, 1.0f), new (0.0f, 1.0f),
            
            // east
            new (0.0f, 0.0f), new (0.5f, 0.0f),
            new (0.5f, 0.5f), new (0.0f, 0.5f),
            
            // west
            new (0.0f, 0.0f), new (0.5f, 0.0f),
            new (0.5f, 0.5f), new (0.0f, 0.5f),
            
            // north
            new (0.0f, 0.0f), new (0.5f, 0.0f),
            new (0.5f, 0.5f), new (0.0f, 0.5f),
            
            // down
            new (0.5f, 0.0f), new (1.0f, 0.0f),
            new (1.0f, 0.5f), new (0.5f, 0.5f)
        };
        
        // define our triangles
        int[] triangles = new int[] {
            0, 3, 2,    0, 2, 1, // south
            4, 7, 6,    4, 6, 5, // up
            8, 11, 10,  8, 10, 9, //east
            12, 15, 14, 12, 14, 13, // west
            16, 19, 18, 16, 18, 17, // north
            20, 21, 22, 20, 22, 23 // down
        };

        mesh = GetComponent<MeshFilter>().mesh;
        mesh.Clear();

        mesh.vertices = vertices;
        mesh.uv = uvs;
        mesh.normals = normals;
        mesh.triangles = triangles;
    }

    void OnDestroy() {
        Destroy(mesh);
    }
}
