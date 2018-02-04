/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#version 120

#include "/lib/Header.glsl"
#define PROGRAM DEFERRED2
#define SHADER FSH
#include "/lib/Syntax.glsl"

/* CONST */
/* USED BUFFER */
#define IN_TEX0
#define IN_TEX1
#define IN_TEX2
#define IN_TEX4

/* VARYING */
varying vec2 screenCoord;

flat(vec3) sunDirection;
flat(vec3) moonDirection;
flat(vec3) lightDirection;
flat(vec3) wLightDirection;

/* UNIFORM */
uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex4;

uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D depthtex2;

uniform sampler2D noisetex;

uniform mat4 gbufferProjection, gbufferProjectionInverse;
uniform mat4 gbufferModelView, gbufferModelViewInverse;

uniform vec3 cameraPosition;

uniform int isEyeInWater;

uniform float sunAngle;
uniform float near;
uniform float far;
uniform float frameTimeCounter;
uniform float rainStrength;

/* GLOBAL */
/* STRUCT */
#include "/lib/struct/Buffers.glsl"
#include "/lib/struct/Gbuffer.glsl"
#include "/lib/struct/Mask.glsl"
#include "/lib/struct/Position.glsl"

/* INCLUDE */
#include "/lib/common/Reflections.glsl"

#include "/lib/common/Clouds.glsl"

/* FUNCTION */
/* MAIN */
void main() {
  // CREATE STRUCT INSTANCES
  _newBufferList(bufferList);
  _newGbufferObject(gbufferData);
  _newMaskList(maskList);
  _newPositionObject(positionData);

  // POPULATE STRUCT INSTANCES
  populateBufferList(bufferList, screenCoord);
  populateGbufferData(gbufferData, bufferList);
  populateMaskList(maskList, gbufferData);
  populateDepths(positionData, screenCoord);
  populateViewPositions(positionData, screenCoord);

  // COMPUTE DITHER
  cv(float) ditherScale = pow(128.0, 2.0);
  vec2 dither = vec2(bayer128(gl_FragCoord.xy), ditherScale);

  // COMPUTE ATMOSPHERE LIGHTING
  mat2x3 atmosphereLighting = getAtmosphereLighting();

  #ifdef SPECULAR_DUAL_LAYER
    // DRAW REFLECTIONS
    if(_getLandMask(positionData.depthBack)) bufferList.tex0.rgb = drawReflections(gbufferData, positionData, bufferList.tex0.rgb, screenCoord, atmosphereLighting, bufferList.tex4, dither);
  #endif

  // COMPUTE CLOUDS
  bufferList.tex4 = computeClouds(positionData, atmosphereLighting, dither);

  // POPULATE OUTGOING BUFFERS
  /* DRAWBUFFERS:04 */
  gl_FragData[0] = bufferList.tex0;
  gl_FragData[1] = bufferList.tex4;
}
