Shader "Unlit/scrollShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {} // The main texture, defaulting to white
        _ScrollSpeedY ("Scroll Speed Y", Float) = 0.5 // Scroll speed in Y direction for vertical scroll
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" } // This shader is for opaque objects
        LOD 100 // The shader's level of detail

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex; // The texture sampler for the main texture
            float _ScrollSpeedY; // The speed variable for vertical scrolling

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            // Pseudo-random noise function
            float rand(float2 co)
            {
                return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Scroll the UVs vertically
                float2 scrolledUV = i.uv + float2(0.0, _ScrollSpeedY) * _Time.y;

                // Sample the texture color with scrolled UVs
                fixed4 texColor = tex2D(_MainTex, scrolledUV);

                // Return the final blended color
                return texColor;
            }
            ENDCG
        }
    }
}