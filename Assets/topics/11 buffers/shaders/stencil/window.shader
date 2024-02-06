Shader "examples/week 11/window"
{
    Properties {
        _stencilRef ("stencil reference", Int) = 1
    }

    SubShader
    {
        Tags {"Queue"="Geometry-1"} // 1999 render queue
        ZWrite Off
        // tells unity to not output the result of the fragment shader to the render target
        ColorMask 0
        
        Stencil
        {
            // value between 0-255 like a variable declaration
            Ref [_stencilRef]
            
            // comp is the compare function. 
            Comp Always
            
            // if comp passes, you can specify a consequence with the pass command
            // replace will write our ref value to the stencil buffer if comp passes
            Pass Replace
        }

        // nothing new below
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
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                return 0;
            }
            ENDCG
        }
    }
}
