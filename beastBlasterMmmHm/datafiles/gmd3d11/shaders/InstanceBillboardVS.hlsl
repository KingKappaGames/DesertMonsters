#include "CommonVS.hlsl"

struct VS_in
{
    float3 Position   : POSITION;
    float3 Normal     : NORMAL0;
    float4 Color      : COLOR0;
    float2 TexCoord   : TEXCOORD0;
    uint   InstanceID : SV_InstanceID;
};

struct VS_out
{
    float4 Position   : SV_POSITION;
    float3 Normal     : NORMAL0;
    float4 Color      : COLOR0;
    float2 TexCoord   : TEXCOORD0;
    float3 WorldPos   : TEXCOORD1;
    uint   InstanceID : TEXCOORD2;
};

struct PhysXTransform {
    float3 Position;
    float  qx;
    float  qy;
    float  qz;
    float  qw;
    float  UserData;
};

StructuredBuffer<PhysXTransform> TransformBuffer : register(t5);

static const float BILLBOARD_SIZE = 1.0;

// Extract camera position from world-view matrix
float3 GetCameraPosition(float4x4 worldView)
{
    float3 translation = float3(worldView[0][3], worldView[1][3], worldView[2][3]);
    
    // Transpose the 3x3 rotation
    float3x3 rotTranspose = float3x3(
        worldView[0][0], worldView[1][0], worldView[2][0],
        worldView[0][1], worldView[1][1], worldView[2][1],
        worldView[0][2], worldView[1][2], worldView[2][2]
    );
    
    return -mul(rotTranspose, translation);
}

void main(in VS_in IN, out VS_out OUT)
{
    PhysXTransform transform = TransformBuffer[IN.InstanceID];
    
    float3 centerPos = transform.Position;
    uint objectID = asuint(transform.UserData);
    
    // Get camera position from world-view matrix
    float3 cameraPos = GetCameraPosition(gm_Matrices[MATRIX_WORLD_VIEW]);
    
    // Calculate view direction from billboard to camera
    float3 toCamera = normalize(cameraPos - centerPos);
    
    // For spherical billboard, extract right and up that face the camera
    float3 worldUp = float3(0, 0, 1);
    
    // Right vector perpendicular to view direction and world up
    float3 billboardRight = normalize(cross(toCamera, worldUp)); 
    
    // Up vector perpendicular to right and view direction
    float3 billboardUp = cross(toCamera, billboardRight);
    
    // Billboard radius
    float billboardRadius = 16.0 * BILLBOARD_SIZE;
    
    // Build billboard quad
    float3 offset = billboardRight * IN.Position.x * billboardRadius + billboardUp * IN.Position.y * billboardRadius;
    float3 worldPos = centerPos + offset;
    
    OUT.Position = mul(gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION], float4(worldPos, 1.0)); // Transform to clip space
    OUT.Normal = toCamera; // Normal points toward camera
    OUT.Color = IN.Color;
    OUT.TexCoord = IN.TexCoord;
    OUT.WorldPos = worldPos;
    OUT.InstanceID = objectID;
}