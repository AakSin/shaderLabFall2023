Shader "examples/week 12/ray marching"
{
        Properties {
        _MainTex ("Texture", 2D) = "white" { }
        _Speed ("Rotation Speed", Range(0, 10)) = 1
        _NumCylinders ("Number of Cylinders", Range(1, 100)) = 100
    }

    SubShader {
        Tags { "RenderType"="Opaque" }

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma exclude_renderers gles xbox360 ps3
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct MeshData {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 hitPos : TEXCOORD1;
            };

            Interpolators vert(MeshData v) {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.hitPos = mul(unity_ObjectToWorld, v.vertex);
                o.uv = v.uv;
                return o;
            }
             int _NumCylinders;
           
            float get_dist(float3 pos) {
                float t = _Time.y;

              
                float radius = 0.5;

                float dCylinder = 500.0; // Set an initial large distance for the minimum

                for (int i = 0; i < _NumCylinders; i++) {
                    float3 rotatedPos = pos;
                     float3 center = float(i*0.5).rrr;
                    // Rotate around the z-axis
                    float angle = t + i * 0.2; // Adjust the rotation speed as needed
                    rotatedPos.yz = float2(cos(t) * pos.x - sin(t) * pos.z, sin(t) * pos.x + cos(t) * pos.z);

                    float currentDist = length(rotatedPos.xy - center.xy) - radius;

                    dCylinder = min(dCylinder, currentDist);
                }

                float planeZPos = 0; // Adjust the Z position of the plane
                float dPlane = abs(pos.z - planeZPos);

                return min(dPlane, dCylinder);
            }


            #define MAX_STEPS 100
            #define MIN_DIST 0.001
            #define MAX_DIST 10

            sampler2D _MainTex;
            float _Speed;
               

            float ray_march(float3 rayOrigin, float3 rayDir) {
                float marchDist = 0;

                for (int i = 0; i < MAX_STEPS; i++) {
                    float3 pos = rayOrigin + rayDir * marchDist;

                    float distToSurf = get_dist(pos);
                    marchDist += distToSurf;

                    if (distToSurf < MIN_DIST || marchDist > MAX_DIST) {
                        break;
                    }
                }

                return marchDist;
            }
  float4 frag(Interpolators i) : SV_Target {
                float3 color = 0;
                float t = _Time.y;
                // Map UV coordinates to the texture
                float2 uv = i.uv;

                // Rotate UVs based on time to give the appearance of texture movement
                uv = uv + float2(_Time.y * _Speed, 0);

                // Sample texture
                color = tex2D(_MainTex, uv);

                float3 camPos = _WorldSpaceCameraPos + float3(sin(t),cos(t),0);
                float3 rayDir = normalize(i.hitPos - camPos);

                float d = ray_march(camPos, rayDir);
                float depth = 1 - (d / MAX_DIST);

                // Apply texture to color
                color *= depth;

                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}