Shader "Unlit/BlendStyle"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
	    _WaveNoise("Noise", 2D) = "white" {}  //用于扭曲的噪声纹理
		_Distort("Distort", float) = 1.0    //扭曲强度
		_SampOffset("SampleOffset", float) = 0.0   //噪声纹理采样偏移
		_Speed("WaveSpeed", float) = 1.0   //水波速度
		_AlphaFadeIn("AlphaFadeIn", float) = 0.0    //透明度淡入
		_AlphaFadeOut("AlphaFadeOut", float) = 1.0   //透明度淡出
		_DistortFadeIn("DistortFadeIn", float) = 1.0    //扭曲淡入
		_DistortFadeOut("DistortFadeOut", float) = 1.0    //扭曲淡出
		_DistortFadeInStrength("DistortFadeInStrength", float) = 1.0   //扭曲淡入时强度
		_DistortFadeOutStrength("DistortFadeOutStrength ", float) = 1.0   //扭曲淡出时强度
		//_ColorMask("Color Mask", Float) = 15
		//_Diffuse("Diffuse",Color) = (1,1,1,1)
		//_White("white",2D)= "white" {}
		//_WhiteColor("White Color" , Color) = (1,1,1,1)

	//	_MainTex("MainTex",2D) = "white" {}
	_Inner("Inner",2D) = "white" {}
	//_WhiteAdjust("white adjust" , Vector) = (0,0,0,0)
	_C1("C1" , Color) = (1,1,1,1)
		_C2("C2" , Color) = (1,1,1,1)
		_C3("C3" , Color) = (1,1,1,1)
		_C4("C4" , Color) = (1,1,1,1)
		_C5("C5" , Color) = (1,1,1,1)
		_t1("t1" , Range(0,0.2)) = 0.1
		_t2("t2" , Range(0.2,0.3)) = 0.25
		_t3("t3" , Range(0.3,0.5)) = 0.45
		_t4("t4" , Range(0.5,0.7)) = 0.66
		_NoiseTex("Noise Texture", 2D) = "white" {}
	_NoiseAmount("Noise Amount", Range(0,1)) = 1
		_NoiseTex1("Noise Texture", 2D) = "white" {}
	_NoiseAmount1("Noise Amount", Range(0,10)) = 1
		_delta1("delta1", Range(0,0.5)) = 0
		_delta2("delta2", Range(0.5,1)) = 1
		_Height("Height",Range(5,20)) = 2
		_Height_Offset("Height Offset",Range(0,8)) = 1
		_dis_factor("dis_factor", Range(0,2)) = 0.8
		_Tooniness("Tooniness" , Range(0.1,20)) = 4
		_tmin("tmin" , Range(0,0.5)) = 0.25
		_tmax("tmax" , Range(0.5,1)) = 0.75
		_Cmin("Cmin" , Range(0,0.5)) = 0.25
		_Cmax("Cmax" , Range(0.5,1)) = 0.75

	}
		SubShader
	{
		Tags
	{
		"Queue" = "Transparent"
		"IgnoreProjector" = "True"
		"RenderType" = "Transparent"
		"PreviewType" = "Plane"
		"CanUseSpriteAtlas" = "True"
	}


		//ColorMask[_ColorMask]
		Pass{
		Tags{ "LightMode" = "ForwardBase" }
		CGPROGRAM
#pragma vertex vert
#pragma fragment frag

#include "Lighting.cginc"
		//define all varaible 
		float _tmin;
	float _tmax;
	float _Cmin;
	float _Cmax;
	float _Height;
	float _Height_Offset;
	sampler2D _Inner;
	float4 _Inner_ST;
	sampler2D _MainTex;
	float4 _MainTex_ST;
	sampler2D _NoiseTex;

	float4 _NoiseTex_ST;
	float _NoiseAmount;
	float _NoiseAmount1;
	float4 _NoiseTex_ST1;
	sampler2D _NoiseTex1;
	fixed4 _C1;
	fixed4 _C2;
	fixed4 _C3;
	fixed4 _C4;
	fixed4 _C5;
	float _t1;
	float _t2;
	float _t3;
	float _t4;
	float _delta2;
	float _delta1;
	float _dis_factor;
	float _Tooniness;
	//float4 _WhiteAdjust;
	//fixed4 _WhiteColor;
	//fixed4 _Diffuse;

	struct a2v
	{
		float4 vertex : POSITION;
		float3 normal : NORMAL;
		float2 texcoord:TEXCOORD0;
	};

	struct v2f
	{
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD1;
		float3 worldNormal:TEXCOORD0;
		float tse : TEXCOORD2;
		float view : TEXCOORD3;
		//float3 view:TEXCOORD3;
	};


	//image processing functions 
	fixed4 GetTooninessColor(fixed4 col)
	{
		fixed4 res = col;
		return floor(col * _Tooniness) / _Tooniness;
	}


	float GaussianLoad1D(float x) {
		float ret = (1.0 / (2.0*3.1415926)) * pow(2.71828, -(x*x / 2.0));
		return ret;
	}


	fixed4 InteriorGaussianBlur(float tdw) {
		fixed4 ret = fixed4(0,0,0,0);
		float temp = 0.0;
		for (float i = -0.4; i <= 0.4; i = i + 0.1) {
			temp = tdw + i;
			if (temp <= _t1) {
				ret += GaussianLoad1D(i) * _C1;
			}
			else if (temp <= _t2) {
				ret += GaussianLoad1D(i) * _C2;
			}
			else if (temp <= _t3) {
				ret += GaussianLoad1D(i) * _C3;
			}
			else if (temp <= _t4) {
				ret += GaussianLoad1D(i) * _C4;
			}
			else {
				ret += GaussianLoad1D(i) * _C5;
			}

		}
		return ret;
	}


	v2f vert(a2v v)
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = v.texcoord.xy * _Inner_ST.xy + _Inner_ST.zw;
		o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
		float3 viewDir = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos.xyz, 1)).xyz - v.vertex;
		o.tse = dot(normalize(viewDir), v.normal);
		float3 temp = mul(unity_ObjectToWorld, v.vertex).xyz - _WorldSpaceCameraPos.xyz;
		o.view = dot(temp, temp);
		//o.view = viewDir;
		return o;
	}

	fixed4 frag(v2f i) : SV_Target
	{

		//get height of model
		float height =  saturate((pow((i.pos.y / _Height - _Height_Offset)/10,3)));
    	//edge detection

		float tse = i.tse;
	   float outline = pow(i.tse,2);
	   if (outline >0.1) {
	    	outline = 1;
	   }
	   else {
	    	outline = 0;
	   }
    	tse = saturate((tse - _delta1) / (_delta2 - _delta1));
    	fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
	    fixed3 worldNormal = normalize(i.worldNormal);
	    fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

	float td = dot(worldNormal, worldLightDir);
	//in this case, we use remap(td,-1,1)
	td = saturate((td + 1) / 2);
	//float2 uv = float2(td, td);
	//weathering parameter tw
	// fixed4 col = GetColorFromTexture( _White , i.uv , _WhiteAdjust )*_WhiteColor;
	fixed4 colored = tex2D(_MainTex, i.uv)*fixed4(1.0,1.0,1.0,1.0);
	colored = GetTooninessColor(colored);
	float4 col = tex2D(_Inner, i.uv);
	float tw = dot(col.rgb,float3(0.3 , 0.59 , 0.11));
	// fixed3 diffuse = _LightColor0 * _Diffuse.rgb * (dot(worldNormal, worldLightDir) * 0.5 + 0.5); // 半兰伯特光照模型
	//fixed3 color = (1.0,1.0,1.0);
	//Mix function
	float tdw = saturate(0.4*tw + 1.6*td - 1);
	//float tdw = td;
	//add some noise to tdw
	float noise = (tex2D(_NoiseTex, i.uv).r - 0.5)*_NoiseAmount;  // 随时间偏移雾效，-0.5是把范围控制在[-0.5,0.5]
	tdw = saturate(tdw + noise);
	//Choose Color Based on tdw

	float noise1 = (tex2D(_NoiseTex1, i.uv).r - 0.5)*_NoiseAmount1;  // 随时间偏移雾效，-0.5是把范围控制在[-0.5,0.5]
	if (tse<0.5) {
		tse = saturate(tse + saturate(noise1));
	}
	else if (tse<0.5) {
		tse = saturate(tse + saturate(noise1*0.5));
	}
	else if (tse<0.6) {
		tse = saturate(tse + saturate(noise1*0.25));
	}
	else {
		tse = 1;
	}

	fixed4 color = InteriorGaussianBlur(tdw*tse);
	//depth paramter
	float zs = i.view / 1000;
	float ta = 1 - exp2(-zs / _dis_factor);
	ta = saturate((ta - _tmin) / (_tmax - _tmin));
	fixed4 Ca = saturate(_Cmin*(1 - color) + _Cmax*color);
	fixed4 Cf = saturate(color*(1 - ta) + Ca*ta);
	//depth paramter
	//float zs = abs(i.view.z);
	/*  float ta = 1 - exp2(- zs);
	ta = saturate((ta - _tmin) / (_tmax - _tmin));
	fixed4 Ca= saturate(_Cmin*(1 - color) + _Cmax*color);
	fixed4 Cf = saturate(color*(1 - ta) + Ca*ta);
	*/
	return Cf;//*outline;//*outline;	//standar diffuse parameter
	}
		ENDCG
	}
		Pass
	{
		Cull Off
		Lighting Off
		ZWrite Off
		//ZTest [unity_GUIZTestMode]
		Blend SrcAlpha OneMinusSrcAlpha

		CGPROGRAM
        #pragma vertex vert
        #pragma fragment frag
        #include "UnityCG.cginc"

		struct appdata_t
	{
		float4 vertex   : POSITION;
		float4 color    : COLOR;
		float2 texcoord : TEXCOORD0;
		//UNITY_VERTEX_INPUT_INSTANCE_ID
	};

	struct v2f
	{
		float4 vertex   : SV_POSITION;
		fixed4 color : COLOR;
		float2 texcoord  : TEXCOORD0;
		float4 worldPosition : TEXCOORD1;
		
		//UNITY_VERTEX_OUTPUT_STEREO
	};
	half _Speed;
	half _Distort;
	half _SampOffset;
	float _AlphaFadeIn;
	float _AlphaFadeOut;
	half _DistortFadeIn;
	half _DistortFadeOut;
	fixed _DistortFadeInStrength;
	fixed _DistortFadeOutStrength;

	sampler2D _MainTex;
	sampler2D _WaveNoise;

	v2f vert(appdata_t IN)
	{
		v2f OUT;
		IN.vertex.y = -IN.vertex.y;
		OUT.worldPosition = IN.vertex;
		OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);
		OUT.texcoord = IN.texcoord;
		OUT.color = IN.color ;
		return OUT;
	}
	fixed4 frag(v2f IN) :SV_Target
	{
		//remap fuction for 
		  //fixed2 duv = (IN.texcoord - fixed2(0.5, 0)) * fixed2(lerp(_DistortFadeOutStrength, _DistortFadeInStrength, fadeD), 1) + fixed2(0.5, 0);
		fixed fadeD = saturate((_DistortFadeOut - IN.texcoord.y) / (_DistortFadeOut - _DistortFadeIn));
		fixed2 duv = IN.texcoord* fixed2(lerp(_DistortFadeOutStrength, _DistortFadeInStrength, fadeD), 1) ;

	    fixed waveL = tex2D(_WaveNoise, duv + fixed2(_SampOffset, _Time.y * _Speed)).r;
	    fixed waveR = tex2D(_WaveNoise, duv + fixed2(-_SampOffset, _Time.y * _Speed)).r;
	    fixed waveU = tex2D(_WaveNoise, duv + fixed2(0, _Time.y * _Speed + _SampOffset)).r;
	    fixed waveD = tex2D(_WaveNoise, duv + fixed2(0, _Time.y * _Speed - _SampOffset)).r;
	    fixed2 uv = fixed2(IN.texcoord.x, 1 - IN.texcoord.y) + fixed2(waveL - waveR, waveU - waveD) * _Distort;
	    half4 color = (tex2D(_MainTex, uv) ) * IN.color;

	    fixed fadeA = saturate((_AlphaFadeOut - uv.y) / (_AlphaFadeOut - _AlphaFadeIn));

	    color.a *= fadeA;
	    return color;


	}
		ENDCG
	}
	}
}

