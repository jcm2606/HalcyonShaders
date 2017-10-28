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

varying vec4 colour;

varying mat3 ttn;

flat(float) objectID;
varying float dist;

// UNIFORM
uniform sampler2D texture;

uniform sampler2D normals;
uniform sampler2D specular;

// STRUCT
#include "/lib/gbuffer/struct/StructGbuffer.glsl"

// ARBITRARY
// INCLUDED FILES
// FUNCTIONS
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

  smoothness = 1.0 - smoothness;

  #undef smoothness
  #undef f0
  #undef emission
  #undef materialPlaceholder

  gbuffer.material = materialVector;

  // POPULATE BUFFERS IN GBUFFER OBJECT
  populateBuffers(gbuffer);

  gbuffer.workingBuffer = toLinear(gbuffer.albedo);

  // POPULATE OUTGOING BUFFERS
  /* DRAWBUFFERS:012 */
  gl_FragData[0] = gbuffer.workingBuffer;
  gl_FragData[1] = gbuffer.gbuffer0;
  gl_FragData[2] = gbuffer.gbuffer1;
}
