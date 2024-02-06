Shader "examples/week 13/origami - glsl to hlsl"
{
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #define t _Time.y

            struct MeshData
            {
                float4 vertex : POSITION;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float4 screenPos : TEXCOORD0;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeScreenPos(o.vertex);
                return o;
            }

            #define R float2x2(cos(a/4.+float4(0,11,33,0)))
            
            float4 frag (Interpolators i) : SV_Target
            {
                float4 O = 0.9;
                
                return O;
            }
            ENDCG
        }
    }
}

/*
    https://www.shadertoy.com/view/ctGyWK
    "Origami" by @XorDev

    I wanted to try out soft shading like paper,
    but quickly discovered it looks better with
    color and looks like bounce lighting!

    X : X.com/XorDev/status/1727206969038213426
    Twigl: twigl.app?ol=true&ss=-NjpcsfowUETZLMr_Ki6

    <512 char playlist: shadertoy.com/playlist/N3SyzR
    Thanks to FabriceNeyret2 for many tricks
*/
//Rotate trick
//#define R mat2(cos(a/4.+vec4(0,11,33,0)))
//
//void mainImage(out vec4 O, vec2 I )
//{
//    //Initialize hue and clear fragcolor
//    vec4 h; O=++h;
//    
//    //Uvs and resolution for scaling
//    vec2 u,r=iResolution.xy;
//    //Alpha, length, angle and iterator/radius
//    for(float A,l,L,a,i=7.;--i>0.;
//            //A = anti-aliased alpha using SDF
//            //Pick layer color
//            O=mix(h=sin(i+a/3.+vec4(1,3,5,0))*.2+.7,O, A=min(--l*r.y*.02,1.))*
//            //Soft shading
//            (l + h + .5*A*u.y/L )/L)
//        
//        //Smoothly rotate a quarter at a time
//        a-=sin(a-=sin(a=iTime*4.+i*.4)),
//        //Scale and center
//        u=(I+I-r)/r.y/.1,
//        //Compute round square SDF
//        L = l = max(length(u -= R*clamp(u*R,-i,i)),1.);
//        
//        
//}