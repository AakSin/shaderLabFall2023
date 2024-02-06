Shader "examples/week 2/polar blend"
{
    Properties
    {
        _spaceBlend ("space blend", Range(0,1)) = 0
        _tau ("tau", Range(-10,10)) = 0
        [NoScaleOffset] _baseTex ("base texture", 2D) = "white" {}
        

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

            #define TAU 6.28318530718

            uniform float _spaceBlend;
            uniform float _tau;
            uniform sampler2D _baseTex;

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
                float2 uv = i.uv * 2.0 - 1.0;
                float2 outUV = uv;
                float4 time = _Time; // _Time is a built in unity shader variable. it gives you the time since level load (t/20, t, t*2, t*3)
                float3 base = tex2D(_baseTex, i.uv).rgb;

                float2 polarUV = float2(atan2(uv.y, uv.x), length(uv));
                polarUV.x = polarUV.x / 0.02 + 0.5;

                // outUV = lerp(uv, polarUV, abs(sin(time.y/4)));
                outUV = lerp(uv, polarUV, 1);

                outUV *= sin(time.y/4)*8;
                outUV = frac(outUV* cos(time.y/4)) ;

                 
                float3 final = lerp(base, float3(outUV.x,outUV.y,0), abs(sin(time.y/4)));
                return float4(final, 1.0);
            }
            ENDCG
        }
    }
}
