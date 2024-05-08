Shader "Unlit/SwirlBlendShader"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _SecondTex ("Second Texture", 2D) = "white" {} // Second texture for blending
        _Center ("Swirl Center", Vector) = (0.5, 0.5, 0, 0) // Center of the swirl effect
        _Strength ("Swirl Strength", Float) = 1.0 // Strength of the swirl effect
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

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

            sampler2D _MainTex; // Main texture sampler
            sampler2D _SecondTex; // Second texture sampler
            float4 _Center; // Center of the swirl
            float _Strength; // Strength of the swirl animation

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Offset UVs by the center
                float2 uv = i.uv - _Center.xy;

                // Convert to polar coordinates
                float angle = atan2(uv.y, uv.x);
                float radius = length(uv);

                // Swirl effect increases with distance from center due to the radius component
                angle += radius * _Strength * sin(_Time.y); 

                // Convert back to cartesian coordinates
                uv.x = cos(angle) * radius;
                uv.y = sin(angle) * radius;

                // Apply non-uniform swirl effect using time-based sine function
                uv.x += sin(_Time.y) * uv.y * _Strength;

                // Re-center the UVs
                uv += _Center.xy;

                // Sample both textures with the swirled UVs
                fixed4 col1 = tex2D(_MainTex, uv);
                fixed4 col2 = tex2D(_SecondTex, uv);

                // Create a fade variable that oscillates between 0 and 1
                float fade = sin(_Time.y * 0.5 + 3.14159) * 0.5 + 0.5; // Oscillates between 0 and 1

                // Blend the two colors based on the fade value
                fixed4 col = lerp(col1, col2, fade);

                // Return the final color
                return col;
            }
            ENDCG
        }
    }
}
