// DebugLinesVS.hlsl
#include "CommonVS.hlsl"

struct VS_in
{
    float3 Position   : POSITION;
    float4 Color      : COLOR0;
    float2 TexCoord   : TEXCOORD0;
    uint   InstanceID : SV_InstanceID;
};

struct VS_out
{
    float4 Position : SV_POSITION;
    float4 Color    : COLOR0;
};

struct DebugLine {
    float3 pos0;    // 12 bytes
    uint color0;    // 4 bytes  
    float3 pos1;    // 12 bytes
    uint color1;    // 4 bytes
    // Total: 32 bytes - matches GMPhysX buffer layout
};

// Structured buffer for debug lines
StructuredBuffer<DebugLine> DebugLines : register(t5);

VS_out main(in VS_in IN)
{
    VS_out OUT;
    
    // Get the debug line data for this instance
    DebugLine debugLine = DebugLines[IN.InstanceID];
    
    // Choose start or end position and color based on TexCoord
    float3 position = (IN.TexCoord.x < 0.5) ? debugLine.pos0 : debugLine.pos1;
    uint packedColor = (IN.TexCoord.x < 0.5) ? debugLine.color0 : debugLine.color1;
    
    // Transform to clip space
    OUT.Position = mul(gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION], float4(position, 1.0));
    
    // Extract color components from packed uint (ABGR format)
    float r = float(packedColor & 0xFF) / 255.0;
    float g = float((packedColor >> 8) & 0xFF) / 255.0;
    float b = float((packedColor >> 16) & 0xFF) / 255.0;
    float a = float((packedColor >> 24) & 0xFF) / 255.0;
    
    OUT.Color = float4(r, g, b, a);
    return OUT;
}