Shader "examples/week 2/polar"
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

            float zigzag (float density, float height, float offset, float2 uv)
            {
                float shape = frac(uv.x * density);
                shape = min(shape, 1-shape);
                // shape *= height;
                // shape += offset;
                // shape -= uv.y;
                shape = smoothstep(0, 0.005, shape * height + offset - uv.y);
                // shape = step(0, shape * height + offset - uv.y);
                return shape;
            }

            #define TAU 6.28318530718
            float4 frag (Interpolators i) : SV_Target
            {
                float2 uv = i.uv * 2 - 1;
                float angle = atan2(uv.y, uv.x);
                angle = angle/TAU + 0.5;
                
                float len = length(uv);
                float2 polar = float2(angle, len);
                polar.x = frac(polar.x + _Time.x);
                
                float output = 0;
                
                output = zigzag(40, 0.1, 0.4, polar);
                return float4(output.rrr, 1.0);
            }
            ENDCG
        }
    }
}
