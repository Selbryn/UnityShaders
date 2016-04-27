Shader "Custom/GhostOutline"
{
	Properties
	{
		_MainTex 	("Texture", 2D) = "white" {}
		_Amount 	("Extrusion Amount", Range(-1,1)) = 0.5
		_Alpha		("Alpha Value", Range(0.0,1.0)) = 0.5
		_SpeedDispl	("Speed Displacement", Range(0.0, 10.0)) = 0.0
	}

	SubShader
	{
		Pass
		{
			Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
		
			Name "Outline"
			Cull Off
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha


			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "SimplexNoise.cginc"
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float2 uvFirst : TEXCOORD1;
				float4 vertex : SV_POSITION;
				float3 normal : COLOR0;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			float _SpeedDispl;
			float _Amount;
			float _Alpha;

			v2f vert (appdata v)
			{
				v2f o;

				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);

				//UV flipping
				float3 norm = mul ((float3x3)UNITY_MATRIX_MV, v.normal);
				norm.x *= UNITY_MATRIX_P[0][0];
    			norm.y *= UNITY_MATRIX_P[1][1];

    			//o.vertex.xy += norm.xy * _Amount * sin(o.vertex.x); 
    			//o.vertex.xy += (norm.xy * _Amount) * ( (snoise(v.vertex + _Time) + 1)/2); 
    			o.vertex.xy += (norm.xy * _Amount) * ( (snoise(v.normal.xy + _Time) + 1)/2); 

    			o.uvFirst = v.uv;
				v.uv.x += (_Time * _SpeedDispl);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return tex2D(_MainTex, i.uvFirst);
			}

			ENDCG
		}


		Pass
		{

			Tags {"Queue"="Opaque"}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 normal : COLOR0;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Amount;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normal = v.normal * 0.5 + 0.5;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return tex2D(_MainTex, i.uv);
			}
			ENDCG
		}
	}
}
