// DebugTrianglesVS.hlsl
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

struct DebugTriangle {
    float3 pos0;    // 12 bytes
    uint color0;    // 4 bytes
    float3 pos1;    // 12 bytes
    uint color1;    // 4 bytes
    float3 pos2;    // 12 bytes
    uint color2;    // 4 bytes
    // Total: 48 bytes - matches GMPhysX buffer layout
};

// Structured buffer for debug triangles
StructuredBuffer<DebugTriangle> DebugTriangles : register(t6);

VS_out main(in VS_in IN)
{
    VS_out OUT;
    
    // Get the debug triangle data for this instance
    DebugTriangle debugTriangle = DebugTriangles[IN.InstanceID];
    
    // Choose vertex based on TexCoord
    float3 position;
    uint packedColor;
    
    if (IN.TexCoord.x < 0.5) {
        // First vertex
        position = debugTriangle.pos0;
        packedColor = debugTriangle.color0;
    } else if (IN.TexCoord.x < 1.5) {
        // Second vertex
        position = debugTriangle.pos1;
        packedColor = debugTriangle.color1;
    } else {
        // Third vertex
        position = debugTriangle.pos2;
        packedColor = debugTriangle.color2;
    }
    
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