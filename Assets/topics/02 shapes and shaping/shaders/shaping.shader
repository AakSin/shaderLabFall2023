Shader "examples/week 2/shaping"
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
                uv = uv * 2 - 1;
                uv *= 2;
                
                float x = uv.x;
                float y = uv.y;

                // uv = abs(uv);
                
                float c = x;
                // c = sin(x) * 0.5 + 0.5;
                // c = cos(x);
                // c = abs(x);
                // c = c*y;
                // c = ceil(x);
                // c = floor(x);                
                // c = frac(x);
                // c = min(x, y);
                // c = max(x, y);
                // c = sign(x);
                // c = step(x, y);
                // c = x;
                c = smoothstep(0, 1, x);
                
                return float4(c.rrr, 1.0);
            }
            ENDCG
        }
    }
}
