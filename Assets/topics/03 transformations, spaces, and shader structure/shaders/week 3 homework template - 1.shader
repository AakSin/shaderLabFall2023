Shader "examples/week 3/homework template"
{
    Properties 
    {
        _hour ("hour", Float) = 0
        _minute ("minute", Float) = 0
        _second ("second", Float) = 0
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

            float _hour;
            float _minute;
            float _second;

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
            float circle (float2 uv, float size) {
                return smoothstep(0.0, 0.005, 1 - length(uv) / size);
            }


            float4 frag (Interpolators i) : SV_Target
            {


                float output = 0;
                float gridSize = _second/2;
                i.uv = i.uv * 2 -1;
                float2 uv = i.uv * gridSize;

                float2 gridUV = frac(uv) * 2 - 1;
                

                
                float3 color = 0;
                for(int j = 0; j < 10; j++) {
                    // make a copy of the uv coordinates to modify in our for loop
                    float2 newUV = gridUV; 
                    
                    float multiplier= (_hour)/24;
                    float warpStrength = tan(multiplier * 0.9);

                    //   float warpStrength = 1;
                    gridUV += cos(uv.yx + float2(multiplier*2, 2)) * warpStrength; //output float2 -- input to float 2
                    gridUV += sin(uv.yx + float2(4, multiplier *4)) * warpStrength;
                    // handle translating the uv space
                    float2 translate = float2(0, 0);
                    translate.x += sin(j*TAU); // translating x by sin of our offset
                    translate.y += cos(j*TAU); // translating y by cos of our offset
                    translate *= j; // scaling translate magnitude
                    
                    newUV += translate; // apply translation to uv space
                    float circ = circle(newUV, 0.5);

                    color +=circ.rrr;
                    color += float3(newUV.x,0,newUV.y);
                }
                

                
                float scaleMagnitude = saturate(1-(_minute/60));
                float2 scale = float2(scaleMagnitude, scaleMagnitude);

                // define 2x2 matrix to scale our coordinate system
                float2x2 scale2D = float2x2 (
                scaleMagnitude, 0,
                0, scaleMagnitude
                );
                
                i.uv = mul(i.uv, scale2D);

                color *= step(0.85, 1-length(i.uv));

                


                
                
                return float4(color, 1.0);
                // return float4(_hour/24, _minute/60, _second/60, 1.0);
            }
            ENDCG
        }
    }
}
