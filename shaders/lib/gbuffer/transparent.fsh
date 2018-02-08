/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

/* CONST */
/* VARYING */
varying vec2 uvCoord;
varying vec2 lightmap;

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

uniform sampler2D noisetex;

uniform float frameTimeCounter;
uniform float rainStrength;

/* GLOBAL */
/* STRUCT */
/* INCLUDE */
#include "/lib/common/Normals.glsl"

#include "/lib/gbuffer/ParallaxWater.glsl"

/* FUNCTION */
/* MAIN */
void main() {
  // TBN
  mat3 tbn = mat3(
    ttn[0].x, ttn[1].x, ttn[2].x,
    ttn[0].y, ttn[1].y, ttn[2].y,
    ttn[0].z, ttn[1].z, ttn[2].z
  );

  // ALBEDO
  vec4 albedo = texture2D(texture, uvCoord) * colour;

  if(compare(objectID, OBJECT_WATER)) albedo = vec4(0.0);

  if(compare(objectID, OBJECT_ICE)) albedo.a = ICE_ALBEDO.a;

  // SAMPLE NORMAL MAP
  vec4 normalMap = texture2D(normals, uvCoord);

  // PUDDLE GENERATION
  //float wetness = 0.0;

  // NORMALS
  cv(float) normalAnisotropy = 1.0;
  vec3 normal = vec3(0.5, 0.5, 1.0);

  #define NORMAL_MAPPING
  #ifdef NORMAL_MAPPING
    normal = texture2D(normals, uvCoord).xyz;
  #endif

  if(normalMap.a == 0.0) normal = vec3(0.5, 0.5, 1.0);

  normal = normal * 2.0 - 1.0;

  normal = normal * vec3(normalAnisotropy) + vec3(0.0, 0.0, 1.0 - normalAnisotropy);

  #if PROGRAM == GBUFFERS_WATER
    if(objectID == OBJECT_WATER) normal = getNormal(getParallax(world, view * ttn, objectID), objectID);
  #endif

  normal = _normalize(normal * tbn);

  // MATERIAL PROPERTIES
  vec4 material = MATERIAL_DEFAULT;

  #define smoothness material.x
  #define f0         material.y
  #define emission   material.z
  #define pourosity  material.w

  vec4 specularMap = texture2D(specular, uvCoord);

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

  if(objectID == OBJECT_WATER) material = MATERIAL_WATER;

  if(objectID == OBJECT_STAINED_GLASS) material = MATERIAL_STAINED_GLASS;

  smoothness = _max(0.0001, smoothness);
  smoothness = 1.0 - smoothness;

  f0 = max(F0_DIELECTRIC, f0);

  // OUTGOING DATA
  /* DRAWBUFFERS:127 */
  gl_FragData[0] = vec4(
    encodeColour(albedo.rgb), encode2x8(lightmap),
    encode2x8(vec2(objectID * objectIDMaxRCP, 1.0)), 1.0
  );
  gl_FragData[1] = vec4(
    encodeNormal(normal), encode2x8(vec2(smoothness, f0)),
    encode2x8(vec2(emission, pourosity)), 1.0
  );
  gl_FragData[2] = albedo;
}
