Shader "examples/week 2/shapes"
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
                float2 uv = i.uv * 2 - 1;
                float shape = 0;

                // circle
                // uv.x *= 2;
                // float cutoff = 0.25;
                // shape = step(cutoff, 1-length(uv));


                // rectangle
                // float2 dim = float2(0.5, sin(_Time.y) * 0.5 + 0.5);
                // float2 shaper = float2(0,0);
                // shaper.x = step(-dim.x, uv.x) * 1-step(dim.x, uv.x);
                // shaper.y = step(-dim.y, uv.y) * 1-step(dim.y, uv.y);
                // shape = shaper.x * shaper.y;

                // right triangle
                shape = 1-step(uv.x, uv.y);
                shape *= step(-0.5, uv.y);
                shape *= 1-step(0.5, uv.x);

                return float4(shape.rrr, 1.0);
            }
            ENDCG
        }
    }
}
