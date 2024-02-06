Shader "examples/week 13/simple outline (two pass example)"
{
    Properties 
    {
        _outlineColor ("outline color", Color) = (0, 0, 0, 0)
        _objectColor ("object color", Color) = (1, 1, 1, 1)
        _outlineOffset ("outline offset", Float) = 1
    }
    SubShader {
        Pass {
            CGINCLUDE
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            float3 _outlineColor;
            float3 _objectColor;
            float _outlineOffset;

            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float3 normal = normalize(i.normal);
                float diffuseFalloff = max(0, dot(normal, float3(0, 1, 0)));
                float halfLambert = pow(diffuseFalloff * 0.5 + 0.5, 2);

                return float4(halfLambert * _objectColor, 1.0);
            }
            ENDCG
        }
    }
}
