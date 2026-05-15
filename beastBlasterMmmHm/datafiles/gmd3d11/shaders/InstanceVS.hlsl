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
    float4 Position : SV_POSITION;
    float3 Normal   : NORMAL0;
    float4 Color    : COLOR0;
    float2 TexCoord : TEXCOORD0;
    float3 WorldPos : TEXCOORD1;
    uint   InstanceID : TEXCOORD2;
    float3 ViewDir : TEXCOORD3; 
};

// Match PhysX's 32-byte layout
struct PhysXTransform {
    float3 Position;     // 12 bytes: px, py, pz
    float  qx;           // 4 bytes
    float  qy;           // 4 bytes
    float  qz;           // 4 bytes
    float  qw;           // 4 bytes
    float  UserData;     // 4 bytes
    // Total: 32 bytes
};

// Structured buffer with 32-byte elements
StructuredBuffer<PhysXTransform> TransformBuffer : register(t5);

static const float INSTANCE_SCALE = 1.0;
uniform float u_instance_scale;

float4x4 QuaternionToMatrix(float4 q)
{
    float4x4 m;
    
    float xx = q.x * q.x;
    float xy = q.x * q.y;
    float xz = q.x * q.z;
    float xw = q.x * q.w;
    
    float yy = q.y * q.y;
    float yz = q.y * q.z;
    float yw = q.y * q.w;
    
    float zz = q.z * q.z;
    float zw = q.z * q.w;
    
    m[0][0] = 1.0f - 2.0f * (yy + zz);
    m[1][0] = 2.0f * (xy - zw);
    m[2][0] = 2.0f * (xz + yw);
    m[3][0] = 0.0f;
    
    m[0][1] = 2.0f * (xy + zw);
    m[1][1] = 1.0f - 2.0f * (xx + zz);
    m[2][1] = 2.0f * (yz - xw);
    m[3][1] = 0.0f;
    
    m[0][2] = 2.0f * (xz - yw);
    m[1][2] = 2.0f * (yz + xw);
    m[2][2] = 1.0f - 2.0f * (xx + yy);
    m[3][2] = 0.0f;
    
    m[0][3] = 0.0f;
    m[1][3] = 0.0f;
    m[2][3] = 0.0f;
    m[3][3] = 1.0f;
    
    return m;
}

void main(in VS_in IN, out VS_out OUT)
{
    // Read transform directly from structured buffer
    PhysXTransform transform = TransformBuffer[IN.InstanceID];
    
    float3 posOffset = transform.Position;
    float4 quaternion = float4(transform.qx, transform.qy, transform.qz, transform.qw);
    uint objectID = asuint(transform.UserData);
    
    // Apply scale
    float3 scale = float3(INSTANCE_SCALE, INSTANCE_SCALE, INSTANCE_SCALE);
    
    // Build rotation matrix
    float4x4 rotMatrix = QuaternionToMatrix(quaternion);
    
    // Transform vertex
    float3 scaledPos = IN.Position.xyz * scale;
    float4 rotatedPos = mul(float4(scaledPos, 1.0), rotMatrix);
    float3 position = rotatedPos.xyz + posOffset;
    
    // Output
    OUT.Position = mul(gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION], float4(position, 1.0));
    
    // Transform normal
    float3 rotatedNormal = mul(float4(IN.Normal.xyz, 0.0), rotMatrix).xyz;
    OUT.Normal = normalize(mul(gm_Matrices[MATRIX_WORLD], float4(rotatedNormal, 0.0)).xyz);
    
    OUT.Color = IN.Color;
    OUT.TexCoord = IN.TexCoord;
    OUT.WorldPos = position;
    OUT.InstanceID = objectID;
    
    // Calculate view direction in view space (camera always at origin in view space)
    float4 viewPos = mul(gm_Matrices[MATRIX_WORLD_VIEW], float4(position, 1.0));
    OUT.ViewDir = -normalize(viewPos.xyz);  // Negated because camera looks down -Z
}