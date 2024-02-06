Shader "examples/week 10/kuwahara"
{
    Properties
    {
        _MainTex ("render texture", 2D) = "white"{}
		_KernelSize("Kernel Size (N)", Int) = 17
    }

    SubShader
    {
        Cull Off
        ZWrite Off
        ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            
            sampler2D _MainTex; float4 _MainTex_TexelSize;
            int _KernelSize;

			/* To avoid recalculating the mean once we have found the region
				with the lowest variance (and because the mean is going to be
				calculated anyway), we'll package both inside a struct.
			*/

              float2 gerstner (float2 value){
                return 0.3 * sin(value  +_Time.x) + 0.2 * sin(value * 2  +_Time.y) + 0.1 * sin(value * 4 +_Time.z) + 0.04 * sin(value * 20 +_Time.y*2) + 0.02 * sin(value * 30 +_Time.z) ;

            }
            float rand (float3 uv) {
                float timeMultiplier = 400;
                float time = _Time.x/2;
                float tx =  pow(smoothstep(0, 1, frac((time * 0.085) * 0.1)), 4) + 1;
                float ty =    pow(smoothstep(0, 1, frac((time  * 0.085) * 0.1)), 4) + 2;
                float tz =   pow(smoothstep(0, 1, frac((time  * 0.085) * 0.1)), 4) + 3;


                // return frac(sin(dot(uv.xyz, float3(tx,ty,tz))) * 43758.5453123);
                return frac(sin(dot(uv.xyz, float3(12.9998, 78.233, 54.296))) );
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
			struct region
			{
				float3 mean;
				float variance;
			};

			/*	Given a region bound and a centre-pixel UV, calculate the mean
				and variance of the region.
			*/
			region calcRegion(int2 lower, int2 upper, int samples, float2 uv)
			{
				region r;
				float3 sum = 0.0;
				float3 squareSum = 0.0;

				for (int x = lower.x; x <= upper.x; ++x)
				{
					for (int y = lower.y; y <= upper.y; ++y)
					{
						float2 offset = float2(_MainTex_TexelSize.x * x, _MainTex_TexelSize.y * y);
						float3 tex = tex2D(_MainTex, uv + offset);
						sum += tex;
						squareSum += tex * tex;
					}
				}

				r.mean = sum / samples;
				float3 variance = abs((squareSum / samples) - (r.mean * r.mean));
				r.variance = length(variance);

				return r;
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

            float3 sample (float2 uv)
            {
                return tex2D(_MainTex, uv);
            }

            float3 convolution (float2 uv, float3x3 kernel) {
                // ts makes sure that we scale our offset by the size of the texel so we make sure to sample the next texel
                float2 ts = _MainTex_TexelSize.xy;
                
                float2 o  = 0;
                float2 n  = float2( 0,  1) * ts;
                float2 e  = float2( 1,  0) * ts;
                float2 s  = float2( 0, -1) * ts;
                float2 w  = float2(-1,  0) * ts;
                float2 nw = float2(-1,  1) * ts;
                float2 ne = float2( 1,  1) * ts;
                float2 se = float2( 1, -1) * ts;
                float2 sw = float2(-1, -1) * ts;
                
                float3 result =
                    sample(uv + nw) * kernel[0][0] + sample(uv + n ) * kernel[1][0] + sample(uv + ne) * kernel[2][0] +
                    sample(uv + w ) * kernel[0][1] + sample(uv + o ) * kernel[1][1] + sample(uv + e ) * kernel[2][1] +
                    sample(uv + sw) * kernel[0][2] + sample(uv + s ) * kernel[1][2] + sample(uv + se) * kernel[2][2];
                
                return result;
            }

            float4 frag (Interpolators i) : SV_Target
            {int upper = ((_KernelSize - 1) / 2) +2 ;
				int lower = -upper +2 ;

				int samples = (upper + 1) * (upper + 1);

				// Calculate the four regional parameters as discussed.

                int2 offset = float2(round(sin(_Time.z*5)*20),round(cos(_Time.y*2)*50));
				region regionA = calcRegion(int2(lower, lower) + offset, int2(0, 0)+ offset, samples, i.uv);
				region regionB = calcRegion(int2(0, lower)+ offset, int2(upper, 0)+ offset, samples, i.uv);
				region regionC = calcRegion(int2(lower, 0)+ offset, int2(0, upper)+ offset, samples, i.uv);
				region regionD = calcRegion(int2(0, 0)+ offset, int2(upper, upper)+ offset, samples, i.uv);

				fixed3 col = regionA.mean;
				fixed minVar = regionA.variance;

                
				/*	Cascade through each region and compare variances - the end
					result will be the that the correct mean is picked for col.
				*/
				float testVal;

               
				testVal = step(regionB.variance, minVar);
				col = lerp(col, regionB.mean, testVal);
				minVar = lerp(minVar, regionB.variance, testVal);
             
				testVal = step(regionC.variance, minVar);
				col = lerp(col, regionC.mean, testVal);
				minVar = lerp(minVar, regionC.variance, testVal);
               

				testVal = step(regionD.variance, minVar);
				col = lerp(col, regionD.mean, testVal);
                float timeC = _Time.y/100;
            col = lerp(lerp(regionA.mean, regionB.mean, sin(_Time.x)),
            lerp(regionC.mean, regionD.mean, sin(_Time.y)),
            sin(_Time.z));
           //   float timeC = _Time.y;
           //  col = lerp(lerp(regionA.mean, regionB.mean, fractal_noise(i.uv)),
           // lerp(regionC.mean, regionD.mean, fractal_noise(i.uv)),
           //   frac(_Time.z));

           // col = lerp(regionA.mean,regionB.mean, fractal_noise(i.uv));
				return fixed4(col, 1.0);
            }
            ENDCG
        }
    }
}