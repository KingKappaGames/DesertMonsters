#include "CommonPS.hlsl"

struct VS_out
{
    float4 Position : SV_POSITION;
    float4 Color    : COLOR0;
};

struct PS_out
{
    float4 Color : SV_Target0;
};

void main(in VS_out IN, out PS_out OUT)
{
    OUT.Color = IN.Color;
}