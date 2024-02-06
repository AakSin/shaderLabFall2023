Shader "examples/week 6/spiderRotation"
{
    Properties
    {
        _rotX ("x rotation", Range(-2,2)) = 0
        _rotY ("y rotation", Range(-2,2)) = 0
        _rotZ ("z rotation", Range(-2,2)) = 0
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

            float _rotX;
            float _rotY;
            float _rotZ;


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
                float4 color : COLOR;
                float3 normal : NORMAL;

            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
                float3 normal : TEXCOORD0;

            };

            float4x4 rotation_matrix (float3 axis, float angle) {
                axis = normalize(axis);
                float s = sin(angle);
                float c = cos(angle);
                float oc = 1.0 - c;
                
                return float4x4(
                oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,  0.0,
                oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,  0.0,
                oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c,           0.0,
                0.0,                                0.0,                                0.0,                                1.0);
            }

            Interpolators vert (MeshData v)
            {
                Interpolators o;

                // set vertex color
                o.color = v.color;
                o.normal = v.normal;

                float4x4 x = rotation_matrix(float3(1, 0, 0), _rotX * TAU * o.color.r);
                float4x4 y = rotation_matrix(float3(0, 1, 0), (cos(_Time.y)/10) * TAU * o.color.r);
                float4x4 z = rotation_matrix(float3(0, 0, 1), (sin(_Time.y)/10) * TAU * o.color.r);

                float4x4 rotation = mul(mul(x, y), z);

                v.vertex = mul(v.vertex, rotation);

                
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                // float3 r = lerp(float3(fractal_noise(i.normal.rgb+_Time.y).rrr)+float3(0.7,0.2,1),float3(fractal_noise(i.normal.rgb+_Time.y).rrr+float3(0.35,0,0)),abs(i.normal.b)) ;
                float3 r = lerp(float3(fractal_noise(i.normal.rgb+_Time.y/3).rrr)+float3(0.4,0.6,1),float3(fractal_noise(i.normal.rgb+_Time.y/3).rrr+float3(0,0,0.35)),abs(i.normal.b)) ;

                // float3 r = lerp(float3(fractal_noise(i.normal.rgb+_Time.y/3).rrr)*float3(0.2,0.3,1),float3(fractal_noise(i.normal.rgb+_Time.y/3).rrr+float3(0,0,0.35)),abs(i.normal.b)) ;
                return float4(r-i.color.r,1);
                // return float4(0.6-i.color.r,0.0,0.0,1.0);
            }
            ENDCG
        }
    }
}
