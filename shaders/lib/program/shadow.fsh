/*
    Jcm2606.
    Halcyon.
    Please read "LICENSE.md" before editing this file.
*/

// Header.
#extension GL_EXT_gpu_shader4 : require

#include "/lib/syntax/Form.glsl"
#define STAGE FSH
#define PROGRAM SHADOW
#include "/lib/Syntax.glsl"
#include "/lib/Utility.glsl"
#include "/lib/Settings.glsl"

#extension GL_ARB_shader_texture_lod : enable

// Constants.
// Varyings.
varying vec3 tint;

varying vec3 viewPosition;
varying vec3 worldPosition;

varying vec3 vertexNormal;

varying vec2 uvCoord;

flat(mat3) tbn;

flat(vec2) entity;

flat(float) materialID;

// Screen Samples.
// Uniforms.
uniform sampler2D texture;
uniform sampler2D normals;

// Structs.
// Globals.
// Includes.
// Functions.
// Main.
void main() {
    vec4 albedo = texture2D(texture, uvCoord) * vec4(tint, 1.0);

    bool isWater = CompareFloat(materialID, MATERIAL_WATER);

    if(isWater)
        albedo.rgb = vec3(1.0);

    vec3 normal = vec3(0.5, 0.5, 1.0);
         normal = texture2D(normals, uvCoord).xyz;
         normal = tbn * (normal * 2.0 - 1.0);

    gl_FragData[0] = albedo;
    gl_FragData[1] = vec4(normal * 0.5 + 0.5, float(isWater));
}
// EOF.
