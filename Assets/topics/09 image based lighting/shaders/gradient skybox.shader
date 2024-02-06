Shader "examples/week 9/gradient skybox"
{
    Properties{
        
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
        Pass
        {
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            
            

            float4 vec4(float x,float y,float z,float w){return float4(x,y,z,w);}
            float4 vec4(float x){return float4(x,x,x,x);}
            float4 vec4(float2 x,float2 y){return float4(float2(x.x,x.y),float2(y.x,y.y));}
            float4 vec4(float3 x,float y){return float4(float3(x.x,x.y,x.z),y);}


            float3 vec3(float x,float y,float z){return float3(x,y,z);}
            float3 vec3(float x){return float3(x,x,x);}
            float3 vec3(float2 x,float y){return float3(float2(x.x,x.y),y);}

            float2 vec2(float x,float y){return float2(x,y);}
            float2 vec2(float x){return float2(x,x);}

            float vec(float x){return float(x);}
            
            

            struct VertexInput {
                float4 vertex : POSITION;
                float2 uv:TEXCOORD0;
                float4 tangent : TANGENT;
                float3 normal : NORMAL;
                //VertexInput
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv:TEXCOORD0;
                //VertexOutput
            };
            
            
            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                o.pos = UnityObjectToClipPos (v.vertex);
                o.uv = v.uv;
                //VertexFactory
                return o;
            }
            
            // CC0 licensed, do what thou wilt.
            const float SEED = 42.0;

            // returns a float between -1.0 and 1.0
            float swayRandomized(float seed, float value)
            {
                float f = floor(value);
                float start = sin((cos(f * seed) + sin(f * 1024.)) * 345. + seed);
                float end   = sin((cos((f+1.) * seed) + sin((f+1.) * 1024.)) * 345. + seed);
                return lerp(start, end, smoothstep(0., 1., value - f));
            }

            // returns a float betweeen -3.0 and 3.0. Does not fmodify con.
            float cosmic(float seed, float3 con)
            {
                float sum = swayRandomized(seed, con.z + con.x);
                sum +=      swayRandomized(seed, con.x + con.y + sum);
                sum +=      swayRandomized(seed, con.y + con.z + sum);
                return sum;
            }


            
            
            fixed4 frag(VertexOutput vertex_output) : SV_Target
            {
                
                // Normalized pixel coordinates (from 0 to 1)
                float2 uv = vertex_output.uv/1;
                // aTime, s, and c could be uniforms in some engines.
                float aTime = _Time.y * 0.16;
                float3 s = vec3(swayRandomized(-16405.31527, aTime - 1.11),
                swayRandomized(-77664.8142, aTime + 1.41),
                swayRandomized(-50993.5190, aTime + 2.61)) * 3. + 1.;
                float3 c = vec3(swayRandomized(-10527.92407, aTime - 1.11),
                swayRandomized(-61557.6687, aTime + 1.41),
                swayRandomized(-43527.8990, aTime + 2.61)) * 3. + 1.;
                float3 con = vec3(0.0004375, 0.0005625, 0.0008125) * aTime + c * uv.x + s * uv.y;
                con.x = cosmic(SEED, con);
                con.y = cosmic(SEED, con);
                con.z = cosmic(SEED, con);
                
                return vec4(sin(con) * 0.5 + 0.5,0,0,0.8);

            }
            ENDCG
        }
    }
}