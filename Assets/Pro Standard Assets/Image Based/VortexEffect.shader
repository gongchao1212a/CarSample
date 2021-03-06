// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'glstate.matrix.mvp' with 'UNITY_MATRIX_MVP'
// Upgrade NOTE: replaced 'glstate.matrix.texture[0]' with 'UNITY_MATRIX_TEXTURE0'
// Upgrade NOTE: replaced 'samplerRECT' with 'sampler2D'
// Upgrade NOTE: replaced 'texRECT' with 'tex2D'

Shader "Hidden/Twist Effect" {
Properties {
	_MainTex ("Base (RGB)", RECT) = "white" {}
}

SubShader
{
	Pass
	{
		ZTest Always Cull Off ZWrite Off
		Fog { Mode off }

CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma fragmentoption ARB_precision_hint_fastest 

#include "UnityCG.cginc"

uniform sampler2D _MainTex;
uniform float4 _MainTex_TexelSize;
uniform float _Angle;
uniform float4 _CenterRadius;

struct v2f {
	float4 pos : POSITION;
	float2 uv : TEXCOORD0;
	float2 uvOrig : TEXCOORD1;
};

v2f vert (appdata_img v)
{
	v2f o;
	o.pos = UnityObjectToClipPos (v.vertex);
	float2 uv = v.texcoord.xy - _CenterRadius.xy;
	o.uv = MultiplyUV (UNITY_MATRIX_TEXTURE0, uv);
	o.uvOrig = uv;
	return o;
}

float4 frag (v2f i) : COLOR
{
	float2 offset = i.uvOrig;
	float angle = 1.0 - length(offset / _CenterRadius.zw);
	angle = max (0, angle);
	angle = angle * angle * _Angle;
	float cosLength, sinLength;
	sincos (angle, sinLength, cosLength);
	
	float2 uv;
	uv.x = cosLength * offset[0] - sinLength * offset[1];
	uv.y = sinLength * offset[0] + cosLength * offset[1];
	uv += _CenterRadius.xy;
	
	#ifdef SHADER_API_OPENGL
	uv *= _MainTex_TexelSize.zw;
	#endif	
	
	return tex2D(_MainTex, uv);
}
ENDCG

	}
}

Fallback off

}