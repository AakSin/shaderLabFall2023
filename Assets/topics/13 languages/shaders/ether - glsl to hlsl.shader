Shader "examples/week 13/ether - glsl to hlsl"
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

float map(float3 p) {
	float3 n = float3(0, 1, 0);
	float k1 = 1.9;
	float k2 = (sin(p.x * k1) + sin(p.z * k1)) * 0.8;
	float k3 = (sin(p.y * k1) + sin(p.z * k1)) * 0.8;
	float w1 = 4.0 - dot(abs(p), normalize(n)) + k2;
	float w2 = 4.0 - dot(abs(p), normalize(n.yzx)) + k3;
	float s1 = length((p.xy + (sin((p.z + p.x) * 2.0) * 0.3% cos((p.z + p.x) * 1.0) * 0.5), 2.0) - 1.0) - 0.2;
	float s2 = length((0.5+p.yz + (sin((p.z + p.x) * 2.0) * 0.3 %cos((p.z + p.x) * 1.0) * 0.3), 2.0) - 1.0) - 0.2;
	return min(w1, min(w2, min(s1, s2)));
}


float2 rot(float2 p, float a) {
	return float2(
		p.x * cos(a) - p.y * sin(a),
		p.x * sin(a) + p.y * cos(a));
}

float4 frag (Interpolators i) : SV_Target
{
    float time = _Time.y
	float2 uv = i.screenPos.xy/i.screenPos.w * 2.0 - 1.0;
	uv.x *= _ScreenParams.x /  _ScreenParams.y;
	float3 dir = normalize(float3(uv, 1.0));
	dir.xz = rot(dir.xz, time * 0.23);dir = dir.yzx;
	dir.xz = rot(dir.xz, time * 0.2);dir = dir.yzx;
	float3 pos = float3(0, 0, time);
	float3 col = (0.0);
	float t = 0.0;
    float tt = 0.0;
	// for(int i = 0 ; i < 100; i++) {
	// 	tt = map(pos + dir * t);
	// 	if(tt < 0.001) break;
	// 	t += tt * 0.45;
	// }
	float3 ip = pos + dir * t;
	col = float3(t * 0.1);
	col = sqrt(col);
	float4 fragColor = float4(0.05*t+abs(dir) * col + max(0.0, map(ip - 0.1) - tt), 1.0); //Thanks! Shane!
    fragColor.a = 1.0 / (t * t * t * t);
    return (fragColor);
}
            
ENDCG
        }
    }
}

// Ether by nimitz 2014 (twitter: @stormoid)
// https://www.shadertoy.com/view/MsjSW3
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License
// Contact the author for other licensing options

// #define t iTime
// mat2 m(float a){float c=cos(a), s=sin(a);return mat2(c,-s,s,c);}
// float map(float3 p){
//     p.xz*= m(t*0.4);p.xy*= m(t*0.3);
//     float3 q = p*2.+t;
//     return length(p+float3(sin(t*0.7)))*log(length(p)+1.) + sin(q.x+sin(q.z+sin(q.y)))*0.5 - 1.;
// }

// void mainImage( out float4 fragColor, in float2 fragCoord ){	
//     float2 p = fragCoord.xy/iResolution.y - float2(.9,.5);
//     float3 cl = float3(0.);
//     float d = 2.5;
//     for(int i=0; i<=5; i++)	{
//         float3 p = float3(0,0,5.) + normalize(float3(p, -1.))*d;
//         float rz = map(p);
//         float f =  clamp((rz - map(p+.1))*0.5, -.1, 1. );
//         float3 l = float3(0.1,0.3,.4) + float3(5., 2.5, 3.)*f;
//         cl = cl*l + smoothstep(2.5, .0, rz)*.7*l;
//         d += min(rz, 1.);
//     }
//     fragColor = float4(cl, 1.);
// }





