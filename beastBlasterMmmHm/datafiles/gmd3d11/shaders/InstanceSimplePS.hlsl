#include "CommonPS.hlsl"

Texture2D customTexture : register(t0);
SamplerState customSampler : register(s0);

struct VS_out
{
    float4 Position : SV_POSITION;
    float3 Normal   : NORMAL0;
    float4 Color    : COLOR0;
    float2 TexCoord : TEXCOORD0;
    float3 WorldPos : TEXCOORD1;
    uint   InstanceID : TEXCOORD2;
};

struct PS_out
{
    float4 Color : SV_Target0;
};

void main(in VS_out IN, out PS_out OUT)
{
    float4 textureColor = customTexture.Sample(customSampler, IN.TexCoord);
    
    if (textureColor.a < 0.01) discard;
    
    float3 N = normalize(IN.Normal);
    float3 L = normalize(float3(0.5, 0.5, 1.0));
    
    float NdotL = max(0.0, dot(N, L));
    
    float ambient = 0.7;
    float diffuse = 0.3;
    
    float lighting = ambient + (diffuse * NdotL);
    
    OUT.Color = float4(textureColor.rgb * lighting, textureColor.a);
}