﻿// Toony Colors Pro+Mobile 2
// (c) 2014-2021 Jean Moreno

Shader "Voodoo/GameOps/SliderRampUltimate"
{
	Properties
	{
		[Enum(Front, 2, Back, 1, Both, 0)] _Cull ("Render Face", Float) = 2.0
		[TCP2ToggleNoKeyword] _ZWrite ("Depth Write", Float) = 1.0
		[HideInInspector] _RenderingMode ("rendering mode", Float) = 0.0
		[HideInInspector] _SrcBlend ("blending source", Float) = 1.0
		[HideInInspector] _DstBlend ("blending destination", Float) = 0.0
		[TCP2Separator]

		[TCP2HeaderHelp(Base)]
		_Color ("Color", Color) = (1,1,1,1)
		[TCP2ColorNoAlpha] _HColor ("Highlight Color", Color) = (0.75,0.75,0.75,1)
		[TCP2ColorNoAlpha] _SColor ("Shadow Color", Color) = (0.2,0.2,0.2,1)
		_MainTex ("Albedo", 2D) = "white" {}
		[TCP2Separator]

		[TCP2Header(Ramp Shading)]
		_RampThreshold ("Threshold", Range(0.01,1)) = 0.5
		_RampSmoothing ("Smoothing", Range(0.001,1)) = 0.5
		[TCP2Separator]
		
		[TCP2HeaderHelp(Specular)]
		[Toggle(TCP2_SPECULAR)] _UseSpecular ("Enable Specular", Float) = 0
		[TCP2ColorNoAlpha] _SpecularColor ("Specular Color", Color) = (0.5,0.5,0.5,1)
		_SpecularToonSize ("Toon Size", Range(0,1)) = 0.25
		_SpecularToonSmoothness ("Toon Smoothness", Range(0.001,0.5)) = 0.05
		[TCP2Separator]
		
		[TCP2HeaderHelp(Rim Outline)]
		[Toggle(TCP2_RIM_OUTLINE)] _UseRim ("Enable Rim Outline", Float) = 0
		[TCP2ColorNoAlpha] _RimColor ("Rim Color", Color) = (0.8,0.8,0.8,0.5)
		_RimMin ("Rim Min", Range(0,2)) = 0.5
		_RimMax ("Rim Max", Range(0,2)) = 1
		[TCP2Separator]

		[TCP2HeaderHelp(Reflections)]
		[Toggle(TCP2_REFLECTIONS)] _UseReflections ("Enable Reflections", Float) = 0
		
		[NoScaleOffset] _Cube ("Reflection Cubemap", Cube) = "black" {}
		[TCP2ColorNoAlpha] _ReflectionCubemapColor ("Color", Color) = (1,1,1,1)
		_ReflectionCubemapRoughness ("Cubemap Roughness", Range(0,1)) = 0.5
		[TCP2Separator]
		
		[TCP2HeaderHelp(MatCap)]
		[Toggle(TCP2_MATCAP)] _UseMatCap ("Enable MatCap", Float) = 0
		[NoScaleOffset] _MatCapTex ("MatCap (RGB)", 2D) = "black" {}
		[TCP2ColorNoAlpha] _MatCapColor ("MatCap Color", Color) = (1,1,1,1)
		[TCP2Separator]
		
		[TCP2HeaderHelp(Normal Mapping)]
		[Toggle(_NORMALMAP)] _UseNormalMap ("Enable Normal Mapping", Float) = 0
		_BumpMap ("Normal Map", 2D) = "bump" {}
		_BumpScale ("Scale", Float) = 1
		[TCP2Separator]
		
		//Avoid compile error if the properties are ending with a drawer
		[HideInInspector] __dummy__ ("unused", Float) = 0
	}

	SubShader
	{
		Tags
		{
			"RenderType"="Opaque"
		}

		CGINCLUDE

		#include "UnityCG.cginc"
		#include "UnityLightingCommon.cginc"	// needed for LightColor

		// Shader Properties
		sampler2D _BumpMap;
		sampler2D _MainTex;
		
		// Shader Properties
		float _BumpScale;
		float4 _MainTex_ST;
		fixed4 _Color;
		fixed4 _MatCapColor;
		float _RampThreshold;
		float _RampSmoothing;
		fixed4 _HColor;
		fixed4 _SColor;
		float _SpecularToonSize;
		float _SpecularToonSmoothness;
		fixed4 _SpecularColor;
		float _RimMin;
		float _RimMax;
		fixed4 _RimColor;
		float _ReflectionCubemapRoughness;
		fixed4 _ReflectionCubemapColor;

		// Instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// Shader Properties
						float4 _BumpMap_ST;
		UNITY_INSTANCING_BUFFER_END(Props)

		samplerCUBE _Cube;
		sampler2D _MatCapTex;

		ENDCG

		// Main Surface Shader
		Blend [_SrcBlend] [_DstBlend]
		Cull [_Cull]
		ZWrite [_ZWrite]

		CGPROGRAM

		#pragma surface surf ToonyColorsCustom vertex:vertex_surface exclude_path:deferred exclude_path:prepass keepalpha nolightmap nofog nolppv keepalpha
		#pragma target 3.0

		//================================================================
		// SHADER KEYWORDS

		#pragma shader_feature TCP2_SPECULAR
		#pragma shader_feature TCP2_RIM_OUTLINE
		#pragma shader_feature TCP2_REFLECTIONS
		#pragma shader_feature _ _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
		#pragma shader_feature TCP2_MATCAP
		#pragma shader_feature _NORMALMAP

		//================================================================
		// STRUCTS

		//Vertex input
		struct appdata_tcp2
		{
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			float4 texcoord0 : TEXCOORD0;
			float4 texcoord1 : TEXCOORD1;
			float4 texcoord2 : TEXCOORD2;
			half4 tangent : TANGENT;
			UNITY_VERTEX_INPUT_INSTANCE_ID
		};

		struct Input
		{
			half3 viewDir;
			half3 tangent;
			half3 worldNormal; INTERNAL_DATA
			half2 matcap;
			float2 texcoord0;
		};

		//================================================================
		// VERTEX FUNCTION

		void vertex_surface(inout appdata_tcp2 v, out Input output)
		{
			UNITY_INITIALIZE_OUTPUT(Input, output);

			// Texture Coordinates
			output.texcoord0.xy = v.texcoord0.xy * _MainTex_ST.xy + _MainTex_ST.zw;

			output.tangent = mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0)).xyz;
			#if defined(TCP2_RIM_OUTLINE)
			#endif
			#if defined(TCP2_MATCAP)
			//MatCap
			float3 worldNorm = normalize(unity_WorldToObject[0].xyz * v.normal.x + unity_WorldToObject[1].xyz * v.normal.y + unity_WorldToObject[2].xyz * v.normal.z);
			worldNorm = mul((float3x3)UNITY_MATRIX_V, worldNorm);
			output.matcap = worldNorm.xy * 0.5 + 0.5;
			#endif

		}

		//================================================================

		//Custom SurfaceOutput
		struct SurfaceOutputCustom
		{
			half atten;
			half3 Albedo;
			half3 Normal;
			half3 worldNormal;
			half3 Emission;
			half Specular;
			half Gloss;
			half Alpha;
			half ndv;
			half ndvRaw;
			float3 normalTS;

			Input input;
			
			// Shader Properties
			float __rampThreshold;
			float __rampSmoothing;
			float3 __highlightColor;
			float3 __shadowColor;
			float __ambientIntensity;
			float __specularToonSize;
			float __specularToonSmoothness;
			float3 __specularColor;
			float __rimMin;
			float __rimMax;
			float3 __rimColor;
			float __rimStrength;
			float __reflectionCubemapRoughness;
			float3 __reflectionCubemapColor;
		};

		//================================================================
		// SURFACE FUNCTION

		void surf(Input input, inout SurfaceOutputCustom output)
		{

			input.worldNormal = WorldNormalVector(input, output.Normal);

			// Shader Properties Sampling
			float4 __normalMap = ( tex2D(_BumpMap, input.texcoord0.xy * UNITY_ACCESS_INSTANCED_PROP(Props, _BumpMap_ST).xy + UNITY_ACCESS_INSTANCED_PROP(Props, _BumpMap_ST).zw).rgba );
			float __bumpScale = ( _BumpScale );
			float4 __albedo = ( tex2D(_MainTex, input.texcoord0.xy).rgba );
			float4 __mainColor = ( _Color.rgba );
			float __alpha = ( __albedo.a * __mainColor.a );
			float3 __matcapColor = ( _MatCapColor.rgb );
			output.__rampThreshold = ( _RampThreshold );
			output.__rampSmoothing = ( _RampSmoothing );
			output.__highlightColor = ( _HColor.rgb );
			output.__shadowColor = ( _SColor.rgb );
			output.__ambientIntensity = ( 1.0 );
			output.__specularToonSize = ( _SpecularToonSize );
			output.__specularToonSmoothness = ( _SpecularToonSmoothness );
			output.__specularColor = ( _SpecularColor.rgb );
			output.__rimMin = ( _RimMin );
			output.__rimMax = ( _RimMax );
			output.__rimColor = ( _RimColor.rgb );
			output.__rimStrength = ( 1.0 );
			output.__reflectionCubemapRoughness = ( _ReflectionCubemapRoughness );
			output.__reflectionCubemapColor = ( _ReflectionCubemapColor.rgb );

			output.input = input;

			#if defined(_NORMALMAP)
			half4 normalMap = half4(0,0,0,0);
			normalMap = __normalMap;
			output.Normal = UnpackScaleNormal(normalMap, __bumpScale);
			output.normalTS = output.Normal;

			#endif

			half3 worldNormal = WorldNormalVector(input, output.Normal);
			output.worldNormal = worldNormal;

			half ndv = abs(dot(input.viewDir, normalize(output.Normal.xyz)));
			half ndvRaw = ndv;
			output.ndv = ndv;
			output.ndvRaw = ndvRaw;

			output.Albedo = __albedo.rgb;
			output.Alpha = __alpha;
			
			output.Albedo *= __mainColor.rgb;
			
			//MatCap
			#if defined(TCP2_MATCAP)
			fixed3 matcap = tex2D(_MatCapTex, input.matcap).rgb * __matcapColor;
			output.Emission += matcap;
			#endif
		}

		//================================================================
		// LIGHTING FUNCTION

		inline half4 LightingToonyColorsCustom(inout SurfaceOutputCustom surface, half3 viewDir, UnityGI gi)
		{
			half ndv = surface.ndv;
			half3 lightDir = gi.light.dir;
			#if defined(UNITY_PASS_FORWARDBASE)
				half3 lightColor = _LightColor0.rgb;
				half atten = surface.atten;
			#else
				//extract attenuation from point/spot lights
				half3 lightColor = _LightColor0.rgb;
				half atten = max(gi.light.color.r, max(gi.light.color.g, gi.light.color.b)) / max(_LightColor0.r, max(_LightColor0.g, _LightColor0.b));
			#endif

			half3 normal = normalize(surface.Normal);
			half ndl = dot(normal, lightDir);
			half3 ramp;
			
			#define		RAMP_THRESHOLD	surface.__rampThreshold
			#define		RAMP_SMOOTH		surface.__rampSmoothing
			ndl = saturate(ndl);
			ramp = smoothstep(RAMP_THRESHOLD - RAMP_SMOOTH*0.5, RAMP_THRESHOLD + RAMP_SMOOTH*0.5, ndl);

			//Apply attenuation (shadowmaps & point/spot lights attenuation)
			ramp *= atten;

			//Highlight/Shadow Colors
			#if !defined(UNITY_PASS_FORWARDBASE)
				ramp = lerp(half3(0,0,0), surface.__highlightColor, ramp);
			#else
				ramp = lerp(surface.__shadowColor, surface.__highlightColor, ramp);
			#endif

			//Output color
			half4 color;
			color.rgb = surface.Albedo * lightColor.rgb * ramp;
			color.a = surface.Alpha;

			// Apply indirect lighting (ambient)
			half occlusion = 1;
			#ifdef UNITY_LIGHT_FUNCTION_APPLY_INDIRECT
				half3 ambient = gi.indirect.diffuse;
				ambient *= surface.Albedo * occlusion * surface.__ambientIntensity;

				color.rgb += ambient;
			#endif

			// Premultiply blending
			#if defined(_ALPHAPREMULTIPLY_ON)
				color.rgb *= color.a;
			#endif

			#if defined(TCP2_SPECULAR)
			//Blinn-Phong Specular
			half3 h = normalize(lightDir + viewDir);
			float ndh = max(0, dot (normal, h));
			float spec = smoothstep(surface.__specularToonSize + surface.__specularToonSmoothness, surface.__specularToonSize - surface.__specularToonSmoothness,1 - (ndh / (1+surface.__specularToonSmoothness)));
			spec *= ndl;
			spec *= atten;
			
			//Apply specular
			color.rgb += spec * lightColor.rgb * surface.__specularColor;
			#endif
			// Rim Outline
			#if defined(TCP2_RIM_OUTLINE)
			#if !defined(UNITY_PASS_FORWARDADD)
			half rim = 1 - surface.ndvRaw;
			rim = ( rim );
			half rimMin = surface.__rimMin;
			half rimMax = surface.__rimMax;
			rim = smoothstep(rimMin, rimMax, rim);
			half3 rimColor = surface.__rimColor;
			half rimStrength = surface.__rimStrength;
			color.rgb = lerp(color.rgb, rimColor, rim * rimStrength);
			#endif
			#endif

			half3 reflections = half3(0, 0, 0);
			#if defined(TCP2_REFLECTIONS)
			// Reflection cubemap
			half3 reflectVector = reflect(-viewDir, surface.worldNormal);
			reflections.rgb += texCUBElod(_Cube, half4(reflectVector.xyz, surface.__reflectionCubemapRoughness * 10.0)).rgb;
			reflections.rgb *= surface.__reflectionCubemapColor;
			#endif
			color.rgb += reflections;

			// Apply alpha to Forward Add passes
			#if defined(_ALPHABLEND_ON) && defined(UNITY_PASS_FORWARDADD)
				color.rgb *= color.a;
			#endif

			return color;
		}

		void LightingToonyColorsCustom_GI(inout SurfaceOutputCustom surface, UnityGIInput data, inout UnityGI gi)
		{
			half3 normal = surface.Normal;

			//GI without reflection probes
			gi = UnityGlobalIllumination(data, 1.0, normal); // occlusion is applied in the lighting function, if necessary

			surface.atten = data.atten; // transfer attenuation to lighting function
			gi.light.color = _LightColor0.rgb; // remove attenuation

		}

		ENDCG

	}

	Fallback "Diffuse"
	CustomEditor "ToonyColorsPro.ShaderGenerator.MaterialInspector_SG2"
}

/* TCP_DATA u config(unity:"2019.4.22f1";ver:"2.7.2";tmplt:"SG2_Template_Default";features:list["UNITY_5_4","UNITY_5_5","UNITY_5_6","UNITY_2017_1","UNITY_2018_1","UNITY_2018_2","UNITY_2018_3","UNITY_2019_1","UNITY_2019_2","UNITY_2019_3","BUMP","BUMP_SCALE","SPEC_LEGACY","SPECULAR","SPECULAR_TOON","SPECULAR_SHADER_FEATURE","RIM_SHADER_FEATURE","REFLECTION_CUBEMAP","REFL_ROUGH","REFLECTION_SHADER_FEATURE","MATCAP_ADD","MATCAP","MATCAP_SHADER_FEATURE","BUMP_SHADER_FEATURE","AUTO_TRANSPARENT_BLENDING","RIM_OUTLINE"];flags:list[];flags_extra:dict[];keywords:dict[RENDER_TYPE="Opaque",RampTextureDrawer="[TCP2Gradient]",RampTextureLabel="Ramp Texture",SHADER_TARGET="3.0",RIM_LABEL="Rim Outline"];shaderProperties:list[,,,,,,,,,,,,,,,,,,,sp(name:"Normal Map";imps:list[imp_mp_texture(uto:True;tov:"";tov_lbl:"";gto:False;sbt:False;scr:False;scv:"";scv_lbl:"";gsc:False;roff:False;goff:False;sin_anm:False;sin_anmv:"";sin_anmv_lbl:"";gsin:False;notile:False;triplanar_local:False;def:"bump";locked_uv:False;uv:0;cc:4;chan:"RGBA";mip:-1;mipprop:False;ssuv_vert:False;ssuv_obj:False;uv_type:Texcoord;uv_chan:"XZ";uv_shaderproperty:__NULL__;prop:"_BumpMap";md:"";gbv:False;custom:False;refs:"";guid:"5966508e-8d89-4dba-a33b-455d25283f8b";op:Multiply;lbl:"Normal Map";gpu_inst:True;locked:False;impl_index:0)];layers:list[];unlocked:list[];clones:dict[];isClone:False)];customTextures:list[];codeInjection:codeInjection(injectedFiles:list[];mark:False);matLayers:list[]) */
/* TCP_HASH c0c552c7a23475e6c6b09edf78d062fd */
