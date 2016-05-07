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

			inout_vertex.vertex.xyz += (out_r * inout_vertex.normal); // Trippy as hell on non-flat objects. You've been warned.
			//inout_vertex.vertex.y += out_r; // Transforms in object-space, not world-space.

			inout_vertex.color *= build_imaginary_color(out_i);
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
