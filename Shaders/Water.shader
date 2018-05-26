// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FX/Water"
{
	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
	//_AlphaTex("Alpha (RGB)", 2D) = "white" {}
	_noiseTex("Noise Tex", 2D) = "white" {}
	_HeatSpeed("Heat speed",Vector) = (0,0,0,0)
		_HeatForce("Heat Force", range(0,0.2)) = 0
		//_hmin("hmin", range(0,1)) = 0
		//_hmax("hmax", range(1,20)) = 2
		[HideInInspector] _ReflectionTex("", 2D) = "white" {}
	}
		SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		LOD 100

		Pass{
		//ZWrite Off
		//Blend SrcAlpha OneMinusSrcAlpha
		Cull Off
		Lighting Off
		ZWrite Off
		//ZTest [unity_GUIZTestMode]
		Blend SrcAlpha OneMinusSrcAlpha
		CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"
		struct v2f
	{
		float2 uv : TEXCOORD0;
		//float4 refl : TEXCOORD1;
		float4 pos : SV_POSITION;
	};
	float4 _MainTex_ST;
	//	float _hmin;
	//float _hmax;
	v2f vert(float4 pos : POSITION, float2 uv : TEXCOORD0)
	{
		v2f o;
		o.pos = UnityObjectToClipPos(pos);
		o.uv = TRANSFORM_TEX(uv, _MainTex);
		//o.refl = ComputeScreenPos(o.pos);
		return o;
	}
	sampler2D _MainTex;
	//sampler2D _AlphaTex;
	sampler2D _noiseTex;
	half4 _HeatSpeed;
	half _HeatForce;
	sampler2D _ReflectionTex;
	fixed4 frag(v2f i) : SV_Target
	{
		//hmin =-5,
		//fading effect for reflection
		//float h = saturate(abs((i.pos.y - _hmin) / (_hmax - _hmin)));


		//float2 offsets = worldNormal.xz*viewVector.y;
		float2 uv = i.uv;
		//float2 refl = i.refl;
		//float4 ref = UNITY_PROJ_COORD(i.refl);
		half2 offsetColor1 = tex2D(_noiseTex, uv + _Time.xz * _HeatSpeed.x).rg;
		half2 offsetColor2 = tex2D(_noiseTex, uv - _Time.yx * _HeatSpeed.y).rg;

		uv.x += ((offsetColor1.r + offsetColor2.r) - 1) * _HeatForce;
		uv.y += ((offsetColor1.g + offsetColor2.g) - 1) * _HeatForce;
		//ref.x += ((offsetColor1.g + offsetColor2.g) - 1) * _HeatForce;
		//ref.y += ((offsetColor1.r + offsetColor2.r) - 1) * _HeatForce;
		//ref.z += ((offsetColor1.r + offsetColor2.r) - 1) * _HeatForce;

		//refl.x += ((offsetColor1.r + offsetColor2.r) - 1) * _HeatForce;
		//refl.y += ((offsetColor1.g + offsetColor2.g) - 1) * _HeatForce;

		fixed4 tex = tex2D(_MainTex, uv);
	//	fixed4 refl = tex2Dproj(_ReflectionTex,ref);
		//tex.a = h;
		//fixed4 reflection = saturate(refl + h - 1);
		return tex ;
	}
		ENDCG
	}
	}
}
