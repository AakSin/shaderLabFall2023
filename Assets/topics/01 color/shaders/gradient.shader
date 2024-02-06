Shader "examples/week 1/gradient"
{
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float2 uv = i.uv;

                float3 color = float3(uv.x, 0.0, uv.y);
                // color = float3(uv.xxx);
                // color = float3(uv.yyy);

                
                // float3 colorA = float3(0.72, 0.04, 0.30);
                // float3 colorB = float3(0.00, 0.57, 0.68);

                // float3 gradientX = lerp(colorA, colorB, uv.x);
                // color = gradientX;
                
                // float3 gradientY = lerp(colorA, colorB, uv.y);
                // color = gradientY;

                // color = (gradientX + gradientY);
                // color /= 2;

                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}
