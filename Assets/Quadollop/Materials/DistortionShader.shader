﻿Shader "Custom/DistortionShader"
{
	Properties
	{
		_Color ("Color", Color) = (1, 1, 1, 1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0, 1)) = 0.5
		_Metallic ("Metallic", Range(0, 1)) = 0.0
		_DistortionDegrees ("Distortion Degrees", Range(0, 360)) = 0
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

		static const float PI = 3.14159265f;
		
		fixed4 build_imaginary_color(
			float point_i)
		{
			fixed4 result_color = fixed4(1, 1, 1, 1);

			float normalized_i = point_i; // When the domain gets specified, that'll be applied here.

			if (normalized_i <= -1.0f)
			{
				result_color = fixed4(0, 0, 1, 1);
			}
			else if (normalized_i <= 0.0f)
			{
				result_color = fixed4((1 + normalized_i), (1 + normalized_i), 1, 1);
			}
			else if (normalized_i <= 1.0f)
			{
				result_color = fixed4(1, (1 - normalized_i), (1 - normalized_i), 1);
			}
			else
			{
				result_color = fixed4(1, 0, 0, 1);
			}

			return result_color;
		}

		float2 rotate_complex_number(
			float2 in_complex,
			float distortion_degrees)
		{
			float projection_radians = (distortion_degrees * (PI / 180));

			float distortion_cosine = cos(projection_radians);
			float distortion_sine = sin(projection_radians);

			return float2(
				((in_complex.x * distortion_cosine) + (in_complex.y * distortion_sine)),
				((in_complex.x * distortion_sine) - (in_complex.y * distortion_cosine)));
		}

		float2 square_complex_number(
			float2 in_complex)
		{
			return float2(
				((in_complex.x * in_complex.x) - (in_complex.y * in_complex.y)),
				(in_complex.x * in_complex.y));
		}

		float2 ripple_complex_number(
			float2 in_complex)
		{
			return float2(
				cos(in_complex.x) * cos(in_complex.y),
				sin(in_complex.x) * sin(in_complex.y));
		}

		sampler2D _MainTex;
		float _DistortionDegrees;

		void vert(
			inout appdata_full inout_vertex)
		{
			float3 world_vertex_pos = mul(_Object2World, inout_vertex.vertex).xyz;
			float2 in_complex = world_vertex_pos.xz;
			// OR
			//float2 in_complex = inout_vertex.texcoord.xy;

			//float2 out_complex = square_complex_number(in_complex);
			float2 out_complex = ripple_complex_number(in_complex);

			out_complex = 
				rotate_complex_number(
					out_complex,
					_DistortionDegrees);

			inout_vertex.vertex.xyz += (out_complex.x * inout_vertex.normal); // Trippy as hell on non-flat objects. You've been warned.
			//inout_vertex.vertex.y += out_complex.x; // Transforms in object-space, not world-space.

			inout_vertex.color *= build_imaginary_color(out_complex.y);
		}

		struct Input
		{
			float2 uv_MainTex;
			fixed4 vertex_color : COLOR;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		void surf(
			Input input, 
			inout SurfaceOutputStandard out_fragment)
		{
			// Albedo comes from a texture tinted by color
			fixed4 color_sample = tex2D(_MainTex, input.uv_MainTex) * (_Color * input.vertex_color);
			out_fragment.Albedo = color_sample.rgb;
			// Metallic and smoothness come from slider variables
			out_fragment.Metallic = _Metallic;
			out_fragment.Smoothness = _Glossiness;
			out_fragment.Alpha = color_sample.a;
		}

		ENDCG
	}
}
