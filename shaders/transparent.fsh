/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

/*
  TODO

  When OptiLad fixes the ping-pong buffers, hopefully adding read-write to the same buffers for gbuffers_water/hand_water, I'll need to rewrite the transparent shader entirely.
  
*/

// CONST
// VARYING
flat(vec2) entity;
varying vec2 uvCoord;
varying vec2 lmCoord;

varying vec3 normal;
varying vec3 vertex;
varying vec3 world;
varying vec3 vView;

varying vec4 colour;

varying mat3 ttn;

flat(float) objectID;
varying float dist;

flat(vec3) sunVector;
flat(vec3) moonVector;
flat(vec3) lightVector;

// UNIFORM
uniform sampler2D texture;

uniform sampler2D normals;
uniform sampler2D specular;

uniform sampler2D depthtex1;
uniform sampler2D depthtex2;
uniform sampler2D gaux4;

uniform sampler2D noisetex;

uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;
uniform sampler2D shadowcolor1;

uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

uniform mat4 shadowProjection;
uniform mat4 shadowModelView;

uniform int isEyeInWater;

uniform float viewWidth;
uniform float viewHeight;
uniform float frameTimeCounter;
uniform float rainStrength;
uniform float near;
uniform float far;

uniform vec3 cameraPosition;

// STRUCT
#include "/lib/gbuffer/struct/StructGbuffer.glsl"

// ARBITRARY
// INCLUDED FILES
#include "/lib/common/Reflections.glsl"

#include "/lib/common/WaterAbsorption.glsl"

#include "/lib/common/TransparentNormals.glsl"

#include "/lib/gbuffer/ParallaxTransparent.glsl"

#include "/lib/common/util/ShadowTransform.glsl"
#include "/lib/opaque/Shadows.glsl"

#include "/lib/gbuffer/DirectionalLightmap.glsl"
#include "/lib/common/Lightmaps.glsl"

// FUNCTIONS
vec4 getTransparentReflections(in vec3 view, in vec3 albedo, in vec3 normal, in float roughness, in float f0, in mat2x3 atmosphereLighting, in float shadowOcclusion) {
  if(isEyeInWater == 1) return vec4(0.0);

  vec4 reflection = getReflections(1, gaux4, vertex, atmosphereLighting, albedo, normal, roughness, f0, vec4(shadowOcclusion), lmCoord.y);

  return vec4(reflection.rgb, reflection.a);
}

vec3 getWaterInteraction(in vec3 colour, in vec2 screenCoord, in vec3 view, in vec3 backView) {
  float dist = distance(view, backView);

  return interactWater(colour, dist);
}

// MAIN
void main() {
  // GENERATE OBJECT MASKS
  bool water = (entity.x == WATER.x || entity.x == WATER.y);

  // GENERATE SCREEN COORDINATE
  vec2 screenCoord = gl_FragCoord.xy / vec2(viewWidth, viewHeight);

  // CREATE GBUFFER OBJECT
  NewGbufferObject(gbuffer);

  // GENERATE TBN MATRIX
  mat3 tbn = mat3(
    ttn[0].x, ttn[1].x, ttn[2].x,
    ttn[0].y, ttn[1].y, ttn[2].y,
    ttn[0].z, ttn[1].z, ttn[2].z
  );

  // GENERATE VIEW VECTOR
  vec3 view = normalize(tbn * vertex);

  // SAMPLE NORMAL MAP
  vec4 normalMap = texture2D(normals, uvCoord);

  // GENERATE GBUFFER DATA
  // ALBEDO
  gbuffer.albedo = texture2D(texture, uvCoord);

  gbuffer.albedo = (water) ? vec4(0.0, 0.0, 0.0, 0.0) : gbuffer.albedo;

  #ifdef WHITE_TEXTURES
    gbuffer.albedo.rgb = vec3(1.0);
  #endif

  // OBJECT ID
  gbuffer.objectID = objectID * objectIDRangeRCP;

  // NORMAL
  float normalMaxAngle = NORMAL_ANGLE_TRANSPARENT;

  vec3 surfaceNormal = getNormal(getParallax(world, view, objectID), objectID);

  surfaceNormal  = surfaceNormal * vec3(normalMaxAngle) + vec3(0.0, 0.0, 1.0 - normalMaxAngle);
  surfaceNormal *= tbn;
  surfaceNormal  = normalize(surfaceNormal);

  gbuffer.normal = surfaceNormal;

  // MATERIAL
  vec4 materialVector = MATERIAL_DEFAULT;

  #define smoothness materialVector.x
  #define f0 materialVector.y
  #define emission materialVector.z
  #define materialPlaceholder materialVector.w

  vec4 specularMap = texture2D(specular, uvCoord);

  #if   RESOURCE_FORMAT == 1
    smoothness = specularMap.x;
    f0 = 0.02;
    emission = 0.0;
    materialPlaceholder = 0.0;
  #elif RESOURCE_FORMAT == 2
    smoothness = specularMap.x;
    f0 = mix(0.02, 0.8, specularMap.y);
    emission = 0.0;
    materialPlaceholder = 0.0;
  #elif RESOURCE_FORMAT == 3
    smoothness = specularMap.x;
    f0 = mix(0.02, 0.8, specularMap.y);
    emission = specularMap.z;
    materialPlaceholder = 0.0;
  #elif RESOURCE_FORMAT == 4
    smoothness = specularMap.z;
    f0 = specularMap.x;
    emission = 1.0 - specularMap.a;
    materialPlaceholder = 0.0;
  #endif
  
  materialVector = (water) ? MATERIAL_WATER : materialVector;
  materialVector = (entity.x == STAINED_GLASS.x || entity.x == STAINED_GLASS.y) ? MATERIAL_STAINED_GLASS : materialVector;

  smoothness = 1.0 - smoothness;

  #undef smoothness
  #undef f0
  #undef emission
  #undef materialPlaceholder

  gbuffer.material = materialVector;

  // LIGHTMAPS
  gbuffer.lightmap = toGamma(pow2(lmCoord * getLightmapShading(lmCoord, surfaceNormal, view, materialVector.x, tbn)));

  // LIGHTING
  mat2x3 atmosphereLighting = getAtmosphereLighting();

  NewShadowObject(shadowObject);

  vec3 backView = clipToView(screenCoord, texture2D(depthtex1, screenCoord).x);

  #if 1
    getShadows(shadowObject, vView, 1.0, true);
  #else
    shadowObject.occlusionSolid = 1.0;
  #endif

  vec3 direct = atmosphereLighting[0] * shadowObject.occlusionFront;
  vec3 sky = atmosphereLighting[1] * getSkyLightmap(gbuffer.lightmap.y, gbuffer.normal);
  vec3 block = blockLightColour * getBlockLightmap(gbuffer.lightmap.x);

  vec3 diffuse = gbuffer.albedo.rgb * (direct + sky + block);

  // POPULATE BUFFERS IN GBUFFER OBJECT
  populateBuffers(gbuffer);

  // DRAW REFLECTIONS
  vec4 reflection = getTransparentReflections(vView, gbuffer.albedo.xyz, gbuffer.normal, materialVector.x, materialVector.y, atmosphereLighting, shadowObject.occlusionFront);

  // DRAW WATER ABSORPTION
  vec3 background = texture2D(gaux4, screenCoord).rgb;
  vec4 absorbedBackground = (water && isEyeInWater == 0) ? vec4(getWaterInteraction(background, screenCoord, vView, backView), 1.0) : vec4(0.0);

  // POPULATE OUTGOING BUFFERS
  /* DRAWBUFFERS:12460 */
  gl_FragData[0] = gbuffer.gbuffer0;
  gl_FragData[1] = gbuffer.gbuffer1;
  gl_FragData[2] = reflection;
  gl_FragData[3] = vec4(diffuse, gbuffer.albedo.a);
  gl_FragData[4] = absorbedBackground;
}
