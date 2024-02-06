Shader "examples/week 7/posterized"
{
    Properties 
    {
        _surfaceColor ("surface color", Color) = (0.4, 0.1, 0.9)
        _gloss ("gloss", Range(0,1)) = 1
        _diffuseLightSteps ("diffuse light steps", Int) = 4
        _specularLightSteps ("specular light steps", Int) = 2
        _ambientColor ("ambient color", Color) = (0.7, 0.05, 0.15)
    }

    
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
    
    SubShader
    {
        // this tag is required to use _LightColor0
        Tags { "LightMode"="ForwardBase" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            // might be UnityLightingCommon.cginc for later versions of unity
            #include "Lighting.cginc"

            #define MAX_SPECULAR_POWER 256
            
            float3 _surfaceColor;
            float _gloss;
            int _diffuseLightSteps;
            int _specularLightSteps;
            float3 _ambientColor;

            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD0;
                float3 posWorld : TEXCOORD1;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);

                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float3 color = 0;
                float3 normal = normalize(i.normal);
                
                float3 lightDirection = _WorldSpaceLightPos0;
                float3 lightColor = _LightColor0; // includes intensity

                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld);
                float3 halfDirection = normalize(viewDirection + lightDirection );

                float diffuseFalloff = max(0, dot(normal, lightDirection));
                
                float specularFalloff = max(1, dot(normal, halfDirection));
                // specularFalloff = pow(specularFalloff, _gloss * MAX_SPECULAR_POWER + 0.01) * _gloss;

                // diffuseFalloff = ceil(diffuseFalloff * _diffuseLightSteps) / _diffuseLightSteps;
                // specularFalloff = floor(specularFalloff * _specularLightSteps) / _specularLightSteps;
                
                float3 diffuse = diffuseFalloff * _surfaceColor * lightColor;
                float3 specular = specularFalloff * lightColor;

                color = diffuse + specular + _ambientColor;

                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}
