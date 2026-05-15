#include "CommonPS.hlsl"

Texture2D customTexture : register(t0);
SamplerState customSampler : register(s0);

cbuffer TimeConstants : register(b0)
{
    float u_time;
}

struct VS_out
{
    float4 Position : SV_POSITION;
    float3 Normal   : NORMAL0;
    float4 Color    : COLOR0;
    float2 TexCoord : TEXCOORD0;
    float3 WorldPos : TEXCOORD1;
    uint InstanceID : TEXCOORD2;
    float3 ViewDir : TEXCOORD3;
};

struct PS_out
{
    float4 Color : SV_Target0;
};

float3 hsvToRgb(float3 hsv)
{
    float h = hsv.x;
    float s = hsv.y;
    float v = hsv.z;
   
    float c = v * s;
    float x = c * (1.0 - abs(fmod(h * 6.0, 2.0) - 1.0));
    float m = v - c;
   
    float3 rgb;
    if (h < 1.0/6.0)      rgb = float3(c, x, 0.0);
    else if (h < 2.0/6.0) rgb = float3(x, c, 0.0);
    else if (h < 3.0/6.0) rgb = float3(0.0, c, x);
    else if (h < 4.0/6.0) rgb = float3(0.0, x, c);
    else if (h < 5.0/6.0) rgb = float3(x, 0.0, c);
    else                  rgb = float3(c, 0.0, x);
   
    return rgb + m;
}

float4 GetPastelColor(uint objectID)
{
    float cycleSpeed = 0.2;
    float startPhase = (float)objectID * 0.1;
    float hue = frac(startPhase + u_time * cycleSpeed);
    float3 hsv = float3(hue, 0.65, 0.95); // Punchy but not overwhelming
    float3 rgb = hsvToRgb(hsv);
    return float4(rgb, 1.0);
}

void main(in VS_out IN, out PS_out OUT)
{
    float4 textureColor = customTexture.Sample(customSampler, IN.TexCoord);
    
    if (textureColor.a < 0.01) discard;

    float4 pastelColor = GetPastelColor(IN.InstanceID);
    
    float3 N = normalize(IN.Normal);
    float3 L = normalize(float3(0.5, 0.5, 1.0));
    float3 V = normalize(IN.ViewDir);
    
    // Diffuse lighting
    float NdotL = max(0.0, dot(N, L));
    float diffuse = lerp(0.6, 1.0, NdotL);
    
    float3 baseColor = textureColor.rgb;
    float3 finalColor = baseColor * diffuse;
    
    // Vibrant rim light with pulse
    float rim = 1.0 - max(0.0, dot(N, V));
    rim = pow(rim, 2.8);
    float rimPulse = 0.6 + 0.15 * sin(u_time * 2.0 + (float)IN.InstanceID * 0.5);
    finalColor += pastelColor.rgb * rim * rimPulse;
    
    // Glossy specular highlight
    float3 H = normalize(L + V);
    float spec = pow(max(0.0, dot(N, H)), 40.0);
    finalColor += pastelColor.rgb * spec * 0.4;
    
    OUT.Color = float4(finalColor, textureColor.a);
}