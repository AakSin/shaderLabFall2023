Shader "examples/week 5/homework"
{
    Properties
    {
        _radius ("radius", Float) = 5
        _morph ("morph", Range(0,1)) = 0
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

            float _radius;
            float _morph;


            float rand (float3 uv) {
                float timeMultiplier = 400;
                float time = _Time.x/2;
                float tx =  pow(smoothstep(0, 1, frac((time * 0.085) * 0.1)), 4) + 1;
                float ty =    pow(smoothstep(0, 1, frac((time  * 0.085) * 0.1)), 4) + 2;
                float tz =   pow(smoothstep(0, 1, frac((time  * 0.085) * 0.1)), 4) + 3;


                // return frac(sin(dot(uv.xyz, float3(tx,ty,tz))) * 43758.5453123);
                return frac(sin(dot(uv.xyz, float3(12.9998, 78.233, 54.296))) * abs(sin(_Time.y)));
            }

            float value_noise (float3 uv) {
                float3 ipos = floor(uv);
                float3 fpos = frac(uv); 
                
                float o  = rand(ipos);
                float x  = rand(ipos + float3(1, 0,0));
                float y  = rand(ipos + float3(0, 1,0));
                float xy = rand(ipos + float3(1, 1,0));

                float3 smooth = smoothstep(0, 1, fpos);
                float lerp1 = lerp( lerp(o,  x, smooth.x), 
                lerp(y, xy, smooth.x), smooth.y);

                o  = rand(ipos+float3(0,0,1));
                x  = rand(ipos + float3(1, 0,1));
                y  = rand(ipos + float3(0, 1,1));
                xy = rand(ipos + float3(1, 1,1));


                float lerp2 = lerp( lerp(o,  x, smooth.x), 
                lerp(y, xy, smooth.x), smooth.y);

                return(lerp(lerp1,lerp2,smooth.z));


            }

            float fractal_noise (float3 uv) {
                float n = 0;

                n  = (1 / 2.0)  * value_noise( uv * 1);
                n += (1 / 4.0)  * value_noise( uv * 2); 
                n += (1 / 8.0)  * value_noise( uv * 4); 
                n += (1 / 16.0) * value_noise( uv * 8);
                
                // n = abs(n);     // create creases
                // n = 1 - n; // invert so creases are at top
                // n = n * n;      // sharpen creases
                return n;
            }


            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;


            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD0;


            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.normal = v.normal;
                v.vertex.xyz = lerp(v.vertex.xyz, normalize(v.vertex.xyz) * fractal_noise (v.vertex.xyz )  , _morph);
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                // float3 r = lerp(float3(0.663,0.431,0.941),float3(0.553,0.82,0.91),abs(i.normal.rgb)) ;
                // float3 r = lerp(float3(abs(sin(_Time.y)),fractal_noise(i.normal.rgb+_Time.y),abs(sin(_Time.y))),float3(abs(cos(_Time.y)),abs(cos(_Time.y)),fractal_noise(i.normal.rgb+_Time.y)),abs(i.normal.rgb)) ;
                float3 r = lerp(float3(fractal_noise(i.normal.rgb+_Time.y).rrr)+float3(0.7,0.2,1),float3(fractal_noise(i.normal.rgb+_Time.y).rrr+float3(0.35,0,0)),abs(i.normal.b)) ;
                // float3 r = lerp((float3(fractal_noise(i.normal.rgb+_Time.y).rrr)+float3(0,0.5,0.7)),(float3(fractal_noise(i.normal.rgb+_Time.y).rrr)+float3(0,0.5,0.7)),abs(i.normal.b)) ;
                float g = abs(i.normal.g) + 0.1;
                float b = abs(i.normal.b) + 0;
                return float4(r, 1.0);
                // return float4(fractal_noise(i.normal.rgb),fractal_noise(i.normal.rgb),fractal_noise(i.normal.rgb), 1.0);
            }
            ENDCG
        }
    }
}
