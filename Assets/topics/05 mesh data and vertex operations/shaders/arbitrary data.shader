Shader "examples/week 5/arbitrary data"
{
    Properties
    {
        _color ("color", Color) = (0, 0, 0.8, 1)
        _scale ("noise scale", Range(2, 100)) = 15.5
        _displacement ("displacement", Range(0, 0.3)) = 0.05
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            float3 _color;
            float _scale;
            float _displacement;

            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float3 color : COLOR;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float2 worldUV : TEXCOORD0;
            };

            float wave (float2 uv) {
                // simple sin wave 0-1 with scale adjustment and time animation
                float wave1 = sin(((uv.x + uv.y) * _scale) + _Time.z) * 0.5 + 0.5;

                // using cos and sin with different uv relationships and time and scale modifiers. 0-2 range
                float wave2 = (cos(((uv.x - uv.y) * _scale/2.568) + _Time.z) + 1) * sin(_Time.x * 5.2321 + (uv.x * uv.y)) * 0.5 + 0.5;
                
                // dividing by 3 to make 0-1 range
                return (wave1 + wave2) / 3;
            }

            Interpolators vert (MeshData v)
            {
                Interpolators o;

                o.worldUV = mul(unity_ObjectToWorld, v.vertex).xz * 0.02;

                v.vertex.y += wave(o.worldUV) * _displacement * v.color.r;
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = v.normal;

                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float3 color = 0;
                float w = wave(i.worldUV);

                float3 topFace = (w.rrr * 0.5 + 0.5) * _color;
                float3 otherFaces = dot(abs(i.normal), float3(0.23, 0.15, 0.41)) * _color;

                color = lerp(otherFaces, topFace, saturate(i.normal.y));
                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}
