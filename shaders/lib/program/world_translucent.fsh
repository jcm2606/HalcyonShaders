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

varying vec3 vertexNormal;

varying vec2 uvCoord;
varying vec2 lmCoord;

varying float vanillaAO;

flat(mat3) tbn;
flat(mat2) tileInfo;

flat(vec2) entity;

flat(float) materialID;

// Screen Samples.
// Uniforms.
uniform sampler2D texture;
uniform sampler2D normals;
uniform sampler2D specular;

// Structs.
// Globals.
// Includes.
#include "/lib/gbuffer/MaterialData.fsh"

// Functions.
// Main.
void main() {
    vec4 albedo = texture2D(texture, uvCoord) * vec4(tint, 1.0);
    float alphaSign = float(albedo.a > 0.05);

    bool isWater = CompareFloat(materialID, MATERIAL_WATER);

    #ifdef NO_ALBEDO
        albedo.rgb = vec3(1.0);
    #endif

    if(isWater)
        albedo = vec4(vec3(0.0), 0.1);

    vec3 normal = vec3(0.5, 0.5, 1.0);
         normal = tbn * (normal * 2.0 - 1.0);

    /* DRAWBUFFERS:015*/
    gl_FragData[0] = vec4(EncodeAlbedo(albedo.rgb), Encode4x8F(vec4(lmCoord, 0.25 /* parallaxShadow */, vanillaAO)), Encode4x8F(vec4(lmCoord, 0.0, 0.0)), 1.0);
    gl_FragData[1] = vec4(EncodeNormal(normal), Encode4x8F(CalculateMaterialData(uvCoord, entity, materialID, 0.0, mat2(0.0))), Encode4x8F(vec4(materialID, 0.0, 0.0, 0.0)), 1.0);
    gl_FragData[2] = albedo;
}
// EOF.
