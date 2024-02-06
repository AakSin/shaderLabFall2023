Shader "examples/week 2/pattern"
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
                float output = 0;
                float gridSize = 40;
                float2 uv = i.uv * gridSize;

                float2 gridUV = frac(uv) * 2 - 1;

                float offset = floor(uv.x) + floor(uv.y);

                float t = _Time.z;
                gridUV.x += cos(t + offset/3) * 0.5;
                gridUV.y += sin(t + offset/3) * 0.5;

                
                float cutoff = 0.5;
                output = step(cutoff, 1-length(gridUV));

                // output = offset /gridSize;
                
                return float4(output.rrr, 1.0);
            }
            ENDCG
        }
    }
}
