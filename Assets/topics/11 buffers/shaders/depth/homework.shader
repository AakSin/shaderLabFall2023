Shader "examples/week 11/depth"
{  Properties
    {

        _EdgeThreshold ("Edge Threshold", Range(0.001, 0.1)) = 0.01
        _EdgeNeighbour("Edge Neighbour", Range(0.001, 0.1)) = 0.01
    }
    SubShader
    {
          GrabPass
        {
            "_BackgroundTex"
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _CameraDepthTexture;
            sampler2D _BackgroundTex;
            float _EdgeThreshold;
            float _EdgeNeighbour;
            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;

            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
          

                float4 screenPos : TEXCOORD0;
                      float2 uv : TEXCOORD1;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.uv = v.uv;
                o.vertex = UnityObjectToClipPos(v.vertex);

                o.screenPos = ComputeScreenPos(o.vertex);
                
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float3 color = 0;
                float2 screenUV = i.screenPos.xy / i.screenPos.w;

                color = Linear01Depth(tex2D(_CameraDepthTexture, screenUV + float2(0, 0))).rrr;
                float3 depthNeighborX = Linear01Depth(tex2D(_CameraDepthTexture, screenUV + float2( _EdgeNeighbour, 0))).rrr;
                float3 depthNeighborY = Linear01Depth(tex2D(_CameraDepthTexture, screenUV + float2(0,  _EdgeNeighbour))).rrr;
                // Compute the depth differences
                float edgeX = abs(depthNeighborX - color);
                float edgeY = abs(depthNeighborY - color);

                // Apply edge threshold
                float edge = saturate(edgeX + edgeY - _EdgeThreshold);
                 float distanceToCenter = distance(screenUV, float2(0.5,0.5));

                float3 background = tex2D(_BackgroundTex, (screenUV-0.5)*2+0.5);
                // Output the edge color if it's an edge, otherwise use the original color
                // return step(edge, 1.0) *  float4(0,0,1,1) + step(1.0, edge) * float4(1,0,0,1);
                return lerp(float4(background,1), float4(1,1,1,1), edge);
                

                return float4(color, 1.0);
            }
            ENDCG
        }
    }
    
    Fallback "Diffuse"
}
