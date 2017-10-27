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

flat(float) material;

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
#include "/lib/gbuffer/ParallaxOpaque.glsl"

#if PROGRAM == GBUFFERS_TERRAIN || PROGRAM == GBUFFERS_HAND
  #define textureSample(tex, coord) texture2DGradARB(tex, coord, parallaxDerivatives[0], parallaxDerivatives[1])
#else
  #define textureSample(tex, coord) texture2D(tex, coord)
#endif

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
        vec3 view = fnormalize(vertex * tbn);
      #endif
    #endif

    // GENERATE PARALLAX VECTOR
    vec2 uv = uvCoord;

    #if PROGRAM == GBUFFERS_TERRAIN || PROGRAM == GBUFFERS_HAND
      uv = getParallaxCoord(view);
    #endif
  #endif

  // GENERATE GBUFFER DATA
  // ALBEDO
  #if PROGRAM == GBUFFERS_BASIC
    gbuffer.albedo = vec4(0.0, 0.0, 0.0, 1.0);
  #elif PROGRAM == GBUFFERS_WEATHER
    gbuffer.albedo = vec4(0.8, 0.9, 1.0, 1.0);
  #elif PROGRAM == GBUFFERS_SKYBASIC
    gbuffer.albedo = colour;
  #else
    gbuffer.albedo = textureSample(texture, uv) * colour;
  #endif

  // POPULATE BUFFERS IN GBUFFER OBJECT
  populateBuffers(gbuffer);

  gbuffer.workingBuffer = gbuffer.albedo;

  // POPULATE OUTGOING BUFFERS
  /* DRAWBUFFERS:012 */
  gl_FragData[0] = gbuffer.workingBuffer;
  gl_FragData[1] = gbuffer.gbuffer0;
  gl_FragData[2] = gbuffer.gbuffer1;
}
