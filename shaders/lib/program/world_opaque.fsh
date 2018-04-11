/*
    Jcm2606.
    Halcyon.
    Please read "LICENSE.md" before editing this file.
*/

#extension GL_ARB_shader_texture_lod : enable

// Constants.
// Varyings.
varying vec3 tint;

varying vec3 viewPosition;
varying vec3 tangentViewVector;
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

uniform mat4 gbufferModelView;

#if PROGRAM == GBUFFERS_TERRAIN || PROGRAM == GBUFFERS_HAND
    uniform vec3 shadowLightPosition;
#endif

// Structs.
// Globals.
// Includes.
#if PROGRAM == GBUFFERS_TERRAIN || PROGRAM == GBUFFERS_HAND
    #include "/lib/gbuffer/ParallaxTerrain.fsh"

    #define textureSample(sampler, coord) texture2DGradARB(sampler, coord, texD[0], texD[1])
#else
    #define textureSample(sampler, coord) texture2D(sampler, coord)
#endif

#include "/lib/gbuffer/LightmapShading.fsh"
#include "/lib/gbuffer/MaterialData.fsh"

// Functions.
// Main.
void main() {
    vec3 viewDirection = normalize(viewPosition * tbn);

    #if PROGRAM == GBUFFERS_TERRAIN || PROGRAM == GBUFFERS_HAND
        mat2 texD     = mat2(dFdx(uvCoord), dFdy(uvCoord));
        vec2 texCoord = CalculateParallaxCoord(uvCoord, viewDirection, texD);

        float parallaxShadow = CalculateParallaxShadow(texCoord, viewPosition, texD);
    #else
        mat2 texD = mat2(0.0);
        vec2 texCoord = uvCoord;

        float parallaxShadow = 1.0;
    #endif

    vec4 albedo = textureSample(texture, texCoord) * vec4(tint, 1.0);

    #ifdef NO_ALBEDO
        albedo.rgb = vec3(1.0);
    #endif

    vec3 normal = vec3(0.5, 0.5, 1.0);

    #if PROGRAM == GBUFFERS_TERRAIN || PROGRAM == GBUFFERS_HAND || PROGRAM == GBUFFERS_ENTITIES
         normal = textureSample(normals, texCoord).xyz;
    #endif

         normal = tbn * (normal * 2.0 - 1.0);

    /* DRAWBUFFERS:014 */
    gl_FragData[0] = vec4(EncodeAlbedo(albedo.rgb), Encode4x8F(vec4(lmCoord, parallaxShadow * 0.25, vanillaAO)), Encode4x8F(vec4(CalculateShadedLightmaps(viewPosition, normal, lmCoord), 0.0, 0.0)), albedo.a);
    gl_FragData[1] = vec4(EncodeNormal(normalize(normal)), Encode4x8F(CalculateMaterialData(texCoord, entity, materialID, 0.0, texD)), Encode4x8F(vec4(materialID, 0.0, 0.0, 0.0)), albedo.a);
    gl_FragData[2] = albedo;
}
// EOF.
