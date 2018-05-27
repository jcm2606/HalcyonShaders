/*
    Jcm2606.
    Halcyon.
    Please read "LICENSE.md" before editing this file.
*/

// Constants.
// Varyings.
varying vec3 tint;

varying vec3 viewPosition;
varying vec3 worldPosition;

varying vec2 uvCoord;
varying vec2 lmCoord;

varying float vanillaAO;

flat(mat3) tbn;

flat(vec2) entity;

flat(float) materialID;

// Screen Samples.
// Uniforms.
uniform sampler2D texture;
uniform sampler2D normals;
uniform sampler2D specular;

uniform sampler2D noisetex;

uniform vec3 cameraPosition;

uniform float frameTimeCounter;
uniform float rainStrength;

// Structs.
// Globals.
// Includes.
#include "/lib/gbuffer/MaterialData.fsh"

#include "/lib/common/WaterNormals.fsh"
#include "/lib/gbuffer/ParallaxWater.fsh"

// Functions.
// Main.
void main() {
    vec4 albedo = texture2D(texture, uvCoord) * vec4(tint, 1.0);
    float alphaSign = float(albedo.a > 0.05);

    bool isWater = CompareFloat(materialID, MATERIAL_WATER);

    vec3 viewDirection = normalize(viewPosition * tbn);

    #ifdef NO_ALBEDO
        albedo.rgb = vec3(1.0);
    #endif

    if(isWater)
        albedo = vec4(vec3(0.0), 0.1);

    vec3 normal = vec3(0.5, 0.5, 1.0);
         normal = texture2D(normals, uvCoord).xyz;
         normal = normalize(normal * 2.0 - 1.0);

    if(isWater)
         normal = CalculateWaterNormal(CalculateWaterParallax(worldPosition + cameraPosition, viewDirection));

         normal = normalize(tbn * normal);

    /* DRAWBUFFERS:015*/
    gl_FragData[0] = vec4(EncodeAlbedo(albedo.rgb), Encode4x8F(vec4(lmCoord, lmCoord)), Encode4x8F(vec4(vec3(1.0), vanillaAO)), ceil(albedo.a));
    gl_FragData[1] = vec4(EncodeNormal(normalize(normal)), Encode4x8F(CalculateMaterialData(uvCoord, entity, materialID, 0.0, mat2(0.0))), Encode4x8F(vec4(materialID, 0.0, 0.0, 0.0)), ceil(albedo.a));
    gl_FragData[2] = albedo;
}
// EOF.
