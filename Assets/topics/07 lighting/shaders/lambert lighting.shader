Shader "examples/week 7/lambert"
{
    Properties 
    {
        _surfaceColor ("surface color", Color) = (0.4, 0.1, 0.9)
    }
    SubShader
    {
        Tags { "LightMode"="ForwardBase" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            
            float3 _surfaceColor;
            
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
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float3 color = 0;
                float3 normal = normalize(i.normal);
                // float lightIntensity = 1;
                // float3 lightDirection = normalize(float3(1,1,1));
                // float3 lightColor = float3(0.9, 0.85, 0.72);
                // lightColor *= lightIntensity;

                float3 lightDirection = _WorldSpaceLightPos0;
                float3 lightColor = _LightColor0;
                
                float falloff = dot(normal, lightDirection);
                falloff = max(0, falloff);

                color = falloff * _surfaceColor * lightColor;

                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}
