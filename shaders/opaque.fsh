/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

// CONST
// VARYING
#if PROGRAM != GBUFFERS_BASIC && PROGRAM != GBUFFERS_SKYBASIC
  varying vec2 uvCoord;

  #if PROGRAM == GBUFFERS_TEXTURED_LIT || PROGRAM == GBUFFERS_TERRAIN || PROGRAM == GBUFFERS_ENTITIES || PROGRAM == GBUFFERS_ITEM || PROGRAM == GBUFFERS_HAND || PROGRAM == GBUFFERS_WEATHER
    varying vec2 lmCoord;
  #endif

  #if PROGRAM != GBUFFERS_SKYTEXTURED
    varying vec3 normal;
    varying vec3 vertex;

    varying mat3 ttn;
  #endif
#endif

#if PROGRAM == GBUFFERS_TERRAIN || PROGRAM == GBUFFERS_HAND
  varying vec4 parallax;

  varying vec3 world;

  flat(vec2) entity;

  varying float dist;
#endif

varying vec4 colour;

flat(float) objectID;

// UNIFORM
#if PROGRAM != GBUFFERS_BASIC && PROGRAM != GBUFFERS_SKYBASIC
  uniform sampler2D texture;
#endif

#if PROGRAM == GBUFFERS_HAND || PROGRAM == GBUFFERS_TERRAIN
  uniform sampler2D normals;
  uniform sampler2D specular;
#endif

// STRUCT
#include "/lib/gbuffer/struct/StructGbuffer.glsl"

// ARBITRARY
// INCLUDED FILES
#if PROGRAM == GBUFFERS_TERRAIN || PROGRAM == GBUFFERS_HAND
  #include "/lib/gbuffer/ParallaxOpaque.glsl"

  #include "/lib/gbuffer/DirectionalLightmap.glsl"

  #define textureSample(tex, coord) texture2DGradARB(tex, coord, parallaxDerivatives[0], parallaxDerivatives[1])
#else
  #define textureSample(tex, coord) texture2D(tex, coord)
#endif

// FUNCTIONS
// MAIN
void main() {
  // CREATE GBUFFER OBJECT
  NewGbufferObject(gbuffer);

  #if PROGRAM != GBUFFERS_BASIC && PROGRAM != GBUFFERS_SKYBASIC
    #if PROGRAM != GBUFFERS_SKYTEXTURED
      // GENERATE TBN MATRIX
      mat3 tbn = mat3(
        ttn[0].x, ttn[1].x, ttn[2].x,
        ttn[0].y, ttn[1].y, ttn[2].y,
        ttn[0].z, ttn[1].z, ttn[2].z
      );

      #if PROGRAM == GBUFFERS_TERRAIN || PROGRAM == GBUFFERS_HAND
        // GENERATE VIEW VECTOR
        vec3 view = normalize(tbn * vertex);
      #endif
    #endif

    // GENERATE PARALLAX VECTOR
    vec2 uv = uvCoord;

    #if PROGRAM == GBUFFERS_TERRAIN || PROGRAM == GBUFFERS_HAND
      // SAMPLE NORMAL MAP (NO PARALLAX)
      mat2x4 normalMap = mat2x4(0.0);

      normalMap[0] = texture2D(normals, uv * parallax.zw + parallax.xy);

      // GENERATE PARALLAX COORDINATE
      uv = getParallaxCoord(view);

      // SAMPLE NORMAL MAP (PARALLAX)
      normalMap[1] = textureSample(normals, uv);
    #endif
  #endif

  // GENERATE GBUFFER DATA
  // ALBEDO
  #if   PROGRAM == GBUFFERS_BASIC
    gbuffer.albedo = vec4(0.0, 0.0, 0.0, 1.0);
  #elif PROGRAM == GBUFFERS_WEATHER
    gbuffer.albedo = vec4(0.8, 0.9, 1.0, 1.0);
  #elif PROGRAM == GBUFFERS_SKYBASIC
    gbuffer.albedo = colour;
  #else
    gbuffer.albedo = textureSample(texture, uv) * colour;
  #endif

  // MATERIAL
  vec4 materialVector = MATERIAL_DEFAULT;

  #define smoothness materialVector.x
  #define f0 materialVector.y
  #define emission materialVector.z
  #define materialPlaceholder materialVector.w

  #if   PROGRAM == GBUFFERS_TERRAIN || PROGRAM == GBUFFERS_HAND
    vec4 specularMap = textureSample(specular, uv);

    // TODO: When I add object masks in, correct these.

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
  #elif PROGRAM == GBUFFERS_ENTITIES
    smoothness = 0.1;
    f0 = 0.02;
    emission = 0.0;
    materialPlaceholder = 0.0;
  #else
    smoothness = 0.0;
    f0 = 0.02;
    emission = 0.0;
    materialPlaceholder = 0.0;
  #endif

  smoothness = 1.0 - smoothness;

  #undef smoothness
  #undef f0
  #undef emission
  #undef materialPlaceholder

  gbuffer.material = materialVector;

  // NORMAL
  #if   PROGRAM == GBUFFERS_TERRAIN
    float normalMaxAngle = mix(NORMAL_ANGLE_OPAQUE, NORMAL_ANGLE_WET, 0.0);

    vec3 surfaceNormal = normalMap[1].xyz * 2.0 - 1.0;
  #elif PROGRAM == GBUFFERS_HAND
    c(float) normalMaxAngle = NORMAL_ANGLE_OPAQUE;

    vec3 surfaceNormal = normalMap[1].xyz * 2.0 - 1.0;
  #elif PROGRAM != GBUFFERS_BASIC && PROGRAM!= GBUFFERS_SKYBASIC && PROGRAM != GBUFFERS_SKYTEXTURED
    vec3 surfaceNormal = normal;
  #else
    vec3 surfaceNormal = vec3(0.0, 0.0, 1.0);
  #endif

  #if PROGRAM == GBUFFERS_TERRAIN || PROGRAM == GBUFFERS_HAND
    surfaceNormal  = surfaceNormal * vec3(normalMaxAngle) + vec3(0.0, 0.0, 1.0 - normalMaxAngle);
    surfaceNormal *= tbn;
    surfaceNormal  = normalize(surfaceNormal);
  #endif

  gbuffer.normal = surfaceNormal;

  // LIGHTMAPS
  #if PROGRAM == GBUFFERS_TEXTURED_LIT || PROGRAM == GBUFFERS_TERRAIN || PROGRAM == GBUFFERS_ENTITIES || PROGRAM == GBUFFERS_ITEM || PROGRAM == GBUFFERS_HAND || PROGRAM == GBUFFERS_WEATHER
    gbuffer.lightmap = ((lmCoord
      #if PROGRAM == GBUFFERS_TERRAIN || PROGRAM == GBUFFERS_HAND
        * getLightmapShading(lmCoord, surfaceNormal, view, materialVector.x, 0.5)
      #endif
    ));
  #endif

  // OBJECT ID
  gbuffer.objectID = objectID * objectIDRangeRCP;

  // POPULATE BUFFERS IN GBUFFER OBJECT
  populateBuffers(gbuffer);

  gbuffer.workingBuffer = gbuffer.albedo;

  // POPULATE OUTGOING BUFFERS
/* DRAWBUFFERS:012 */
  gl_FragData[0] = gbuffer.workingBuffer;
  gl_FragData[1] = gbuffer.gbuffer0;
  gl_FragData[2] = gbuffer.gbuffer1;
}
