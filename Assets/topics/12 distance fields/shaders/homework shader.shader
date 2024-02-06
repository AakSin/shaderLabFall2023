Shader "examples/week 12/homework" {
    Properties {
        _Speed ("Rotation Speed", Range(0, 10)) = 1
        _Scale ("Scale", Range(0, 10)) = 1
    }

    SubShader {
        Tags { "RenderType"="Opaque" "LightMode"="ForwardBase"}

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma exclude_renderers gles xbox360 ps3
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            #define MAX_STEPS 100
            #define MAX_DIST 100
            #define MIN_DIST 0.001

            float _Speed;
            float _Scale;

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

            float sdf_torus(float2 t, float2 r, float3 pos) {
                float2 q = float2(length(pos.xz) - t.x, pos.y);
                return length(q) - r.x;
            }

            float smin(float a, float b) {
                float k = _Scale;
                float h = max(k - abs(a - b), 0.0) / k;
                return min(a, b) - h * h * h * k * (1.0 / 6.0);
            }

            float get_dist(float3 pos) {
                float t = _Time.y * _Speed;

                float distances[4];
                distances[0] = sdf_torus(float2(1, 0.2), float2(0.5, 0.1), pos.xz - float2(sin(t),
                                cos(t));
                distances[1] = sdf_torus(float2(0.8, 0.1), float2(0.4, 0.05), pos.xz + float2(cos(t), sin(t)));
                distances[2] = sdf_torus(float2(1.2, 0.3), float2(0.6, 0.2), pos.xz - float2(sin(t), -cos(t)));
                distances[3] = sdf_torus(float2(0.6, 0.2), float2(0.3, 0.1), pos.xz + float2(cos(t), -sin(t)));

                float m = MAX_DIST;
                for (int i = 0; i < 4; i++) {
                    m = smin(m, distances[i]);
                }

                return m;
            }

            float3 get_normal(float3 pos) {
                float distAtPos = get_dist(pos);
                float sampleDelta = 0.001;
                float3 sampleVec = float3(
                    get_dist(pos + float3(sampleDelta, 0, 0)),
                    get_dist(pos + float3(0, sampleDelta, 0)),
                    get_dist(pos + float3(0, 0, sampleDelta))
                );

                float3 normal = normalize(sampleVec - distAtPos);
                return normal;
            }

            float ray_march(float3 rayOrigin, float3 rayDir) {
                float marchDist = 0;

                for (int i = 0; i < MAX_STEPS; i++) {
                    float3 pos = rayOrigin + rayDir * marchDist;
                    float distToSurf = get_dist(pos);
                    marchDist += distToSurf;

                    if (distToSurf < MIN_DIST || marchDist > MAX_DIST) break;
                }

                return marchDist;
            }

            float4 frag(Interpolators i) : SV_Target {
                float3 color = 0;
                float3 normal = float3(0, 1, 0);

                float3 camPos = _WorldSpaceCameraPos;
                float3 rayDir = normalize(i.hitPos - camPos);
                float d = ray_march(camPos, rayDir);

                normal = get_normal(camPos + rayDir * d);

                float3 lightDirection = _WorldSpaceLightPos0;
                float3 lightColor = _LightColor0;

                float diffuseFalloff = max(0, dot(normal, lightDirection));
                float halfLambert = pow(diffuseFalloff * 0.5 + 0.5, 2);
                float3 diffuse = halfLambert * lightColor;

                diffuse *= 1 - step(MAX_DIST, d);
                color = diffuse;

                if (d >= MAX_DIST) {
                    discard;
                }

                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}
