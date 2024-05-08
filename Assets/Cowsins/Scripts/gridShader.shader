Shader "Custom/AnimatedGridShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _TimePhase ("Time for Full Cycle", Float) = 4.0
        _MovementFactor ("Movement Factor", Float) = 1.0 // Increase for more movement
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

            sampler2D _MainTex;
            float _TimePhase;
            float _MovementFactor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float phase = (_Time.y % _TimePhase) / _TimePhase; // Scale to a unit vector
                float gridStep = 1.0 / 6.0; // 6x6 grid
                float2 gridPos = floor(i.uv / gridStep); // Grid position of the current square

                // Determine checkerboard pattern
                bool isCheckerPattern = int(gridPos.x + gridPos.y) % 2 == 0;

                // Adjust phase transitions for the tile movement
                float movementPhase = phase * 4.0; // Scales phase to [0,4] range for a fully cycle
                float movementDirection = isCheckerPattern ? 1.0 : -1.0; // Direction based on checkered pattern
                float movementStep = gridStep * _MovementFactor; // Move a whole tile over

                // Calculate offset based on current phase and movement factor, accounting for it to wrap around the boundaries
                float2 offset = float2(0, 0);
                if (movementPhase < 1.0) // Right or Left
                {
                    offset.x = movementPhase * movementStep * movementDirection;
                }
                else if (movementPhase < 2.0) // Up
                {
                    offset.x = movementStep * movementDirection;
                    offset.y = (movementPhase - 1.0) * movementStep * movementDirection;
                }
                else if (movementPhase < 3.0) // Left or Right
                {
                    offset.x = (3.0 - movementPhase) * movementStep * movementDirection;
                    offset.y = movementStep * movementDirection;
                }
                else // Down
                {
                    offset.y = (4.0 - movementPhase) * movementStep * movementDirection;
                }

                // Wrapping manually with offset adjustments
                offset = offset % 1.0; // Ensure offset wraps properly

                // Slight scale down to the UV to avoid some border sampling
                float shrinkFactor = 0.995; 
                float2 adjustedUV = i.uv + offset;
                adjustedUV = (adjustedUV - 0.5) * shrinkFactor + 0.5;

                // Clamping to avoid any more border sampling
                adjustedUV = clamp(adjustedUV, 0.002, 0.998);

                // Texture wrapping
                adjustedUV = adjustedUV - floor(adjustedUV); // Wrap UVs to [0,1] range

                // Sample the texture with modified and wrapped UVs
                fixed4 col = tex2D(_MainTex, adjustedUV);
                return col;
            }
            ENDCG
        }
    }
}
