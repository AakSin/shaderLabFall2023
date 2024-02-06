Shader "examples/week 8/homework"
{
    Properties 
    {
        _albedo ("albedo", 2D) = "white" {}
        [NoScaleOffset] _normalMap ("normal map", 2D) = "bump" {}
        [NoScaleOffset] _displacementMap ("displacement map", 2D) = "white" {}
        _gloss ("gloss", Range(0,1)) = 1
        _normalIntensity ("normal intensity", Range(0, 1)) = 1
        _displacementIntensity ("displacement intensity", Range(0,1)) = 0.5
        _refractionIntensity ("refraction intensity", Range(0, 0.5)) = 0.1
        _opacity ("opacity", Range(0,1)) = 0.9
    }
    SubShader
    {
        // this tag is required to use _LightColor0
        // this shader won't actually use transparency, but we want it to render with the transparent objects
        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "LightMode"="ForwardBase" }

        GrabPass {
            "_BackgroundTex"
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc" // might be UnityLightingCommon.cginc for later versions of unity

            #define MAX_SPECULAR_POWER 256

            sampler2D _albedo; float4 _albedo_ST;
            sampler2D _normalMap;
            sampler2D _displacementMap;
            sampler2D _BackgroundTex;
            float _gloss;
            float _normalIntensity;
            float _displacementIntensity;
            float _refractionIntensity;
            float _opacity;

            float3 gerstner (float3 value){
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

            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 tangent : TEXCOORD2;
                float3 bitangent : TEXCOORD3;
                float3 posWorld : TEXCOORD4;
                
                // create a variable to hold two float2 direction vectors that we'll use to pan our textures
                float4 uvPan : TEXCOORD5;
                float4 screenUV : TEXCOORD6;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.uv = TRANSFORM_TEX(v.uv, _albedo);
                
                // panning
                o.uvPan = float4(float2(0.9, 0.2) * _Time.y/5, float2(0.5, -0.2) * _Time.y/5);

                // add our panning to our displacement texture sample
                float height = tex2Dlod(_displacementMap, float4(o.uv + o.uvPan.xy, 0, 0)).r;
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);

                height = gerstner(o.posWorld);
                v.vertex.xyz += v.normal * height * _displacementIntensity;

                o.normal = UnityObjectToWorldNormal(v.normal);
                o.tangent = UnityObjectToWorldNormal(v.tangent);
                o.bitangent = cross(o.normal, o.tangent) * v.tangent.w;

                o.vertex = UnityObjectToClipPos(v.vertex);
                
                o.screenUV = ComputeGrabScreenPos(o.vertex);
                
                
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float2 uv = i.uv;
                float2 screenUV = i.screenUV.xy / i.screenUV.w;
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld);

                // float3 tangentSpaceNormal = UnpackNormal(tex2D(_normalMap, uv + i.uvPan.xy));

                // float3 tangent = float3(1,0,viewDirection*cos(i.posWorld));
                // float3 bitangent = float3(0,1,viewDirection*cos(i.posWorld));
                // float3 mathNormal = float3(cos(i.normal.xz),0);
                float3 mathNormal = gerstner(i.posWorld);


                float3 tangentSpaceNormal = UnpackNormal(tex2D(_normalMap, uv + i.uvPan.xy));

                
                tangentSpaceNormal = normalize(lerp(float3(0, 0, 1), mathNormal, _normalIntensity));
                
                float2 refractionUV = screenUV.xy + (tangentSpaceNormal.xy * _refractionIntensity);
                float3 background = tex2D(_BackgroundTex, refractionUV);
                // background = fractal_noise(background * 10 + _Time.x) * background;
                background=background*fractal_noise((i.screenUV*30)+_Time.y/2) + background;


                float3x3 tangentToWorld = float3x3 
                (
                i.tangent.x, i.bitangent.x, i.normal.x,
                i.tangent.y, i.bitangent.y, i.normal.y,
                i.tangent.z, i.bitangent.z, i.normal.z
                );

                float3 normal = mul(tangentToWorld, tangentSpaceNormal);


                // blinn phong
                float3 surfaceColor = tex2D(_albedo, uv + i.uvPan.xy).rgb;

                float3 lightDirection = _WorldSpaceLightPos0;
                float3 lightColor = _LightColor0; // includes intensity

                
                float3 halfDirection = normalize(viewDirection + lightDirection);

                float diffuseFalloff = max(0, dot(normal, lightDirection));
                float specularFalloff = max(0, dot(normal, halfDirection));

                float3 specular = pow(specularFalloff, _gloss * MAX_SPECULAR_POWER + 0.0001) * _gloss * lightColor;
                float3 diffuse = diffuseFalloff * surfaceColor * lightColor;

                float3 color = (diffuse * _opacity) + (background * (1 - _opacity)) + specular;

                return float4(color, 1);
            }
            ENDCG
        }
    }
}
