Shader "examples/week 4/assignment"
{
    Properties
    {
        // _tex ("texture", 2D) = "white"{}
        _scale ("noise scale", Range(2, 30)) = 15.5
        _intensity ("noise intensity", Range(0.001, 0.05)) = 0.006
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

            sampler2D _tex;
            float _scale;
            float _intensity;

            float rand (float2 uv) {
                return frac(sin(dot(uv.xy, float2(12.9898, 78.233))) * 43758.5453123);
            }

            float noise (float2 uv) {
                float2 ipos = floor(uv);
                float2 fpos = frac(uv); 
                
                float o  = rand(ipos);
                float x  = rand(ipos + float2(1, 0));
                float y  = rand(ipos + float2(0, 1));
                float xy = rand(ipos + float2(1, 1));

                float2 smooth = smoothstep(0, 1, fpos);
                return lerp( lerp(o,  x, smooth.x), 
                lerp(y, xy, smooth.x), smooth.y);
            }

            float fractal_noise (float2 uv) {
                float n = 0;
                // fractal noise is created by adding together "octaves" of a noise
                // an octave is another noise value that is half the amplitude and double the frequency of the previously added noise
                // below the uv is multiplied by a value double the previous. multiplying the uv changes the "frequency" or scale of the noise becuase it scales the underlying grid that is used to create the value noise
                // the noise result from each line is multiplied by a value half of the previous value to change the "amplitude" or intensity or just how much that noise contributes to the overall resulting fractal noise.

                n  = (1 / 2.0)  * noise( uv * 1);
                n += (1 / 4.0)  * noise( uv * 2); 
                n += (1 / 8.0)  * noise( uv * 4); 
                n += (1 / 16.0) * noise( uv * 8);
                
                return n;
            }

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
                float gridSize = 1;
                float2 uv = i.uv * gridSize;

                float2 gridUV = frac(uv) * 2 - 1;

                float t = sin(_Time.y/10) * 10;

                float n = fractal_noise(gridUV);
                float xOffset =  sin(n*t);
                float yOffset =  cos(n*t);

                gridUV+=float2(xOffset,yOffset);


                float cutoff = 0.8;
                output = smoothstep(0,cutoff, 1-length(gridUV)) ;

                float r =  (n+t);
                float g =  (sin(n+t) * 0.5 + 1);
                float b =  (cos(n+t) * 0.5 + 1);
                
                return float4(output *r,output*g,output *b,1.0);
                
                return float4(gridUV.x,0,gridUV.y, 1.0);
                
                // try different ways of using time
                float time = 2;
                time = _Time.y;
                // time = floor(_Time.z);
                // time = pow(sin(_Time.y), 8);

                /*
                sample value noise at uv + time
                scale coordinates to scale noise output
                subtract 0.5 for a range between -0.5 and 0.5
                multiply by _intensity
                */
                // float n = (fractal_noise((uv + time) * _scale) - 0.5) * _intensity;

                // add our noise value to our uv coordinates when we sample the texture
                // float3 color = tex2D(_tex, uv + n).rgb;
                // uv+=n;


                
                // return float4(fractal_noise(uv),fractal_noise(uv),fractal_noise(uv), 1.0);
            }
            ENDCG
        }
    }
}
