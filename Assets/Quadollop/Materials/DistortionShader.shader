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
			float3 in_world_vertex = mul(_Object2World, inout_vertex.vertex).xyz;
			float in_r = in_world_vertex.x;
			float in_i = in_world_vertex.z;
			// OR
			//float in_r = inout_vertex.texcoord.x;
			//float in_i = inout_vertex.texcoord.y;

			// "out = in^2"
			float out_r = (in_r * in_r) - (in_i * in_i);
			float out_i = 2 * (in_r * in_i);

			inout_vertex.vertex.xyz += (out_r * mul(_World2Object, inout_vertex.normal)); // Trippy as hell on non-flat objects. You've been warned.
			//inout_vertex.vertex.y += out_r; // Transforms in object-space, not world-space.
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
