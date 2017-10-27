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
attribute vec4 at_tangent;
attribute vec4 mc_midTexCoord;
attribute vec4 mc_Entity;

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

uniform vec3 cameraPosition;

// ARBITRARY
// INCLUDED FILES
// FUNCTIONS
// MAIN
void main() {
  colour = gl_Color;

  #if PROGRAM == GBUFFERS_TERRAIN || PROGRAM == GBUFFERS_HAND
    entity = mc_Entity.xz;
  #endif
  //#include "/lib/gbuffer/Materials.glsl"

  #if PROGRAM != GBUFFERS_BASIC && PROGRAM != GBUFFERS_SKYBASIC
    uvCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

    #if PROGRAM == GBUFFERS_TEXTURED_LIT || PROGRAM == GBUFFERS_TERRAIN || PROGRAM == GBUFFERS_ENTITIES || PROGRAM == GBUFFERS_ITEM || PROGRAM == GBUFFERS_HAND || PROGRAM == GBUFFERS_WEATHER
      lmCoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    #endif
  #endif

  #if PROGRAM == GBUFFERS_TERRAIN || PROGRAM == GBUFFERS_HAND
    vec2 mid = (gl_TextureMatrix[0] * mc_midTexCoord).xy;
    vec2 uvMinusMid = gl_MultiTexCoord0.xy - mid;
    parallax.zw = abs(uvMinusMid) * 2.0;
    parallax.xy = min(uvCoord, mid - uvMinusMid);

    uvCoord = sign(uvMinusMid) * 0.5 + 0.5;
  #endif

  #if PROGRAM == GBUFFERS_TERRAIN
    vec3 position = deprojectVertex(gbufferModelViewInverse, gl_ModelViewMatrix, gl_Vertex.xyz);
    world = position + cameraPosition;
  #endif

  // ADD-IN POINT: Vertex deformation.
  // ADD-IN POINT: Waving terrain.

  #if PROGRAM == GBUFFERS_TERRAIN
    gl_Position = reprojectVertex(gbufferModelView, position);
  #else
    gl_Position = reprojectVertex(gl_ModelViewMatrix, gl_Vertex.xyz);
  #endif

  #if PROGRAM != GBUFFERS_BASIC && PROGRAM != GBUFFERS_SKYBASIC && PROGRAM != GBUFFERS_SKYTEXTURED
    normal = normalize(gl_NormalMatrix * gl_Normal);

    vertex = (gl_ModelViewMatrix * gl_Vertex).xyz;

    ttn = mat3(0.0);

    ttn[0] = normalize(gl_NormalMatrix * at_tangent.xyz);
    ttn[1] = cross(ttn[0], normal);
    ttn[2] = normal;
  #endif

  #if PROGRAM == GBUFFERS_TERRAIN || PROGRAM == GBUFFERS_HAND
    dist = flength(vertex);
  #endif
}
