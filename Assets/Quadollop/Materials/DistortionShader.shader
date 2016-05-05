Shader "Custom/DistortionShader"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
	}

	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows vertex:vert

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;

		void vert(
			inout appdata_full inout_vertex)
		{
			inout_vertex.vertex.xyz += (inout_vertex.normal * 2.0f);
		}

		struct Input
		{
			float2 uv_MainTex;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		void surf(
			Input input, 
			inout SurfaceOutputStandard out_fragment)
		{
			// Albedo comes from a texture tinted by color
			fixed4 color_sample = tex2D (_MainTex, input.uv_MainTex) * _Color;
			out_fragment.Albedo = color_sample.rgb;
			// Metallic and smoothness come from slider variables
			out_fragment.Metallic = _Metallic;
			out_fragment.Smoothness = _Glossiness;
			out_fragment.Alpha = color_sample.a;
		}
		ENDCG
	}
}
