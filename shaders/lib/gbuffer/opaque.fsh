/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

/* CONST */
/* VARYING */
varying vec2 uvCoord;
varying vec2 lightmap;
varying vec4 parallax;

varying vec4 colour;

varying vec3 view;
varying vec3 world;

varying mat3 ttn;

flat(vec2) entity;
flat(float) objectID;

varying float dist;

/* UNIFORM */
uniform sampler2D texture;
uniform sampler2D normals;
uniform sampler2D specular;

/* GLOBAL */
/* STRUCT */
/* INCLUDE */
#include "/lib/gbuffer/DirectionalLighting.glsl"

#include "/lib/gbuffer/ParallaxTerrain.glsl"

#if PROGRAM == GBUFFERS_TERRAIN || PROGRAM == GBUFFERS_HAND
  #define _textureSample(tex, coord) texture2DGradARB(tex, coord, parallaxDerivatives[0], parallaxDerivatives[1])
#else
  #define _textureSample(tex, coord) texture2D(tex, coord)
#endif

/* FUNCTION */
/* MAIN */
void main() {
  // TBN
  mat3 tbn = mat3(
    ttn[0].x, ttn[1].x, ttn[2].x,
    ttn[0].y, ttn[1].y, ttn[2].y,
    ttn[0].z, ttn[1].z, ttn[2].z
  );

  // PARALLAX
  #if PROGRAM == GBUFFERS_TERRAIN || PROGRAM == GBUFFERS_HAND
    vec2 coord = getParallaxCoord(tbn * view);
  #else
    vec2 coord = uvCoord;
  #endif

  // ALBEDO
  vec4 albedo = _textureSample(texture, coord) * colour;

  // PUDDLE GENERATION
  //float wetness = 0.0;

  // NORMALS
  cv(float) normalAnisotropy = 1.0;
  vec3 normal = vec3(0.5, 0.5, 1.0);

  #if PROGRAM == GBUFFERS_TERRAIN || PROGRAM == GBUFFERS_HAND || PROGRAM == GBUFFERS_ITEM || PROGRAM == GBUFFERS_BLOCK
    #define NORMAL_MAPPING
    #ifdef NORMAL_MAPPING
      normal = _textureSample(normals, coord).xyz;
    #endif
  #endif

  normal = normal * 2.0 - 1.0;

  normal = normal * vec3(normalAnisotropy) + vec3(0.0, 0.0, 1.0 - normalAnisotropy);

  normal = normalize(normal * tbn);

  // MATERIAL PROPERTIES
  vec4 material = MATERIAL_DEFAULT;

  #define smoothness material.x
  #define f0         material.y
  #define emission   material.z
  #define pourosity  material.w

  #if   PROGRAM == GBUFFERS_TERRAIN || PROGRAM == GBUFFERS_HAND || PROGRAM == GBUFFERS_ITEM
    vec4 specularMap = _textureSample(specular, coord);

    #if   SPECULAR_FORMAT == 1
      smoothness = specularMap.r;
      f0 = F0_DIELECTRIC;
      emission = 0.0;
      pourosity = 0.0;
    #elif SPECULAR_FORMAT == 2
      smoothness = specularMap.r;
      f0 = mix(F0_DIELECTRIC, F0_METAL, specularMap.g);
      emission = 0.0;
      pourosity = 0.0;
    #elif SPECULAR_FORMAT == 3
      smoothness = specularMap.r;
      f0 = mix(F0_DIELECTRIC, F0_METAL, specularMap.g);
      emission = specularMap.b;
      pourosity = 0.0;
    #elif SPECULAR_FORMAT == 4
      smoothness = specularMap.b;
      f0 = specularMap.r;
      emission = (1.0 - specularMap.a) * (float(compare(objectID, OBJECT_SUBSURFACE)));
      pourosity = specularMap.g;
    #endif
  #elif PROGRAM == GBUFFERS_ENTITIES

  #endif

  smoothness = _max(0.0001, smoothness);
  smoothness = 1.0 - smoothness;

  f0 = max(0.02, f0);

  // OUTGOING DATA
  /* DRAWBUFFERS:012 */
  gl_FragData[0] = albedo;
  gl_FragData[1] = vec4(
    encodeColour(albedo.rgb), encode2x8(lightmap * getDirectionalLightmaps(lightmap, normal, view, smoothness)),
    encode2x8(vec2(objectID * objectIDMaxRCP, 1.0)), albedo.a
  );
  gl_FragData[2] = vec4(
    encodeNormal(normal), encode2x8(vec2(smoothness, f0)),
    encode2x8(vec2(emission, pourosity)), albedo.a
  );
}
