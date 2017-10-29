/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
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

uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

uniform int isEyeInWater;

uniform float viewWidth;
uniform float viewHeight;

// STRUCT
#include "/lib/gbuffer/struct/StructGbuffer.glsl"

#include "/lib/common/Reflections.glsl"

// ARBITRARY
// INCLUDED FILES
// FUNCTIONS
vec4 getTransparentReflections(in vec3 view, in vec3 albedo, in vec3 normal, in float roughness, in float f0) {
  vec2 screenCoord = gl_FragCoord.xy / vec2(viewWidth, viewHeight);
  vec3 sview = worldToView(vertex);

  vec4 reflection = getReflections(gaux4, vView, screenCoord, gl_FragCoord.z, albedo, normal, roughness, f0);

  return vec4(reflection.rgb, reflection.a);
}

// MAIN
void main() {
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

  gbuffer.albedo = (entity.x == WATER.x || entity.x == WATER.y) ? vec4(0.0, 0.0, 0.0, 0.0) : gbuffer.albedo;

  // LIGHTMAPS
  gbuffer.lightmap = toGamma(pow2(lmCoord));

  // OBJECT ID
  gbuffer.objectID = objectID * objectIDRangeRCP;

  // NORMAL
  float normalMaxAngle = NORMAL_ANGLE_TRANSPARENT;

  vec3 surfaceNormal = normalMap.xyz * 2.0 - 1.0;

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
  
  materialVector = (entity.x == WATER.x || entity.x == WATER.y) ? MATERIAL_WATER : materialVector;

  smoothness = 1.0 - smoothness;

  #undef smoothness
  #undef f0
  #undef emission
  #undef materialPlaceholder

  gbuffer.material = materialVector;

  // POPULATE BUFFERS IN GBUFFER OBJECT
  populateBuffers(gbuffer);

  gbuffer.workingBuffer = toLinear(gbuffer.albedo);

  // DRAW REFLECTIONS
  vec4 reflection = getTransparentReflections(view, gbuffer.albedo.xyz, gbuffer.normal, materialVector.x, materialVector.y);

  // POPULATE OUTGOING BUFFERS
  /* DRAWBUFFERS:12450 */
  gl_FragData[0] = gbuffer.gbuffer0;
  gl_FragData[1] = gbuffer.gbuffer1;
  gl_FragData[2] = reflection;
  gl_FragData[3] = gbuffer.albedo;
  gl_FragData[4] = gbuffer.workingBuffer;
}
