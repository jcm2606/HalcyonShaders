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

uniform sampler2D noisetex;

uniform vec3 cameraPosition;

uniform float frameTimeCounter;
uniform float rainStrength;

// Structs.
// Globals.
// Includes.
#include "/lib/common/WaterNormals.fsh"

// Functions.
// Main.
void main() {
    vec4 albedo = texture2D(texture, uvCoord) * vec4(tint, 1.0);

    bool isWater = CompareFloat(materialID, MATERIAL_WATER);

    if(isWater)
        albedo.rgb = vec3(1.0);

    vec3 normal = vec3(0.5, 0.5, 1.0);
         normal = texture2D(normals, uvCoord).xyz;
         normal = normal * 2.0 - 1.0;

    if(isWater)
         normal = CalculateWaterNormal(worldPosition);

         normal = normalize(tbn * normal);
        
    if(isWater) {
        vec3 refractedPosition = refract(normalize(worldPosition), normal, 0.75) + worldPosition;

        float oldArea = fLength(dFdx(worldPosition)) * fLength(dFdy(worldPosition));
        float newArea = fLength(dFdx(refractedPosition)) * fLength(dFdy(refractedPosition));

        albedo.rgb = vec3(abs(pow2(oldArea / newArea)));
    }

    gl_FragData[0] = vec4(EncodeShadow(albedo.rgb), albedo.a);
    gl_FragData[1] = vec4(normal * 0.5 + 0.5, float(isWater));
}
// EOF.
