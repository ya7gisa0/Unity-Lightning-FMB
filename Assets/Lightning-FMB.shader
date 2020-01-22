// converted this shader by LeGuignon (https://www.shadertoy.com/view/Mds3W7)
Shader "Unlit/Lightning-FMB"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

			float rand(float2 n) {
				return frac(sin(dot(n, float2(12.9898, 4.1414))) * 43758.5453);
			}

			float noise(float2 n) {
				static const float2 d = float2(0.0, 1.0);
				float2 b = floor(n), f = smoothstep(float2(0.0, 0.0), float2(1.0, 1.0), frac(n));
				return lerp(lerp(rand(b), rand(b + d.yx), f.x), lerp(rand(b + d.xy), rand(b + d.yy), f.x), f.y);
			}

			float fbm(float2 n) {
				float total = 0.0, amplitude = 1.0;
				for (int i = 0; i < 7; i++) {
					total += noise(n) * amplitude;
					n += n;
					amplitude *= 0.5;
				}
				return total;
			}

            fixed4 frag (v2f i) : SV_Target
            {
				float4 col = float4(0, 0, 0, 1);
				float2 uv = i.uv.xy; //fragCoord.xy * 1.0 / iResolution.xy
				
				float2 t = uv * float2(2.0, 1.0) - _Time.y*3.0;
				float2 t2 = (float2(1, -1) + uv) * float2(2.0, 1.0) - _Time.y*3.0;

				// draw the lines
				float ycenter = lerp(0.5, 0.25 + 0.25*fbm(t), uv.x*4.0);
				float ycenter2 = lerp(0.5, 0.25 + 0.25*fbm(t2), uv.x*4.0);

				// falloff
				float diff = abs(uv.y - ycenter);
				float c1 = 1.0 - lerp(0.0, 1.0, diff*20.0);

				float diff2 = abs(uv.y - ycenter2);
				float c2 = 1.0 - lerp(0.0, 1.0, diff2*20.0);

				float c = max(c1, c2);
				col = float4(c*0.6, 0.2*c2, c, 1.0);

				return col;
            }
            ENDCG
        }
    }
}
