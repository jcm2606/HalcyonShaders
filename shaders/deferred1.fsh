/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#version 120

#include "/lib/Header.glsl"
#define PROGRAM DEFERRED1
#define SHADER FSH
#include "/lib/Syntax.glsl"

/* CONST */
/* USED BUFFER */
#define IN_TEX0
#define IN_TEX1
#define IN_TEX2

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
uniform sampler2D colortex5;

uniform sampler2D depthtex0;
uniform sampler2D depthtex1;

uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;
uniform sampler2D shadowcolor1;

uniform sampler2D noisetex;

uniform mat4 gbufferProjection, gbufferProjectionInverse;
uniform mat4 gbufferModelView, gbufferModelViewInverse;

uniform mat4 shadowProjection, shadowProjectionInverse;
uniform mat4 shadowModelView;

uniform vec3 cameraPosition;

uniform float sunAngle;
uniform float near;
uniform float far;
uniform float frameTimeCounter;
uniform float rainStrength;

uniform int isEyeInWater;

/* GLOBAL */
/* STRUCT */
#include "/lib/struct/Buffers.glsl"
#include "/lib/struct/Gbuffer.glsl"
#include "/lib/struct/Mask.glsl"
#include "/lib/struct/Position.glsl"

/* INCLUDE */
#include "/lib/common/Sky.glsl"

#include "/lib/common/Caustics.glsl"

#include "/lib/forward/Shading.glsl"

#include "/lib/common/AtmosphereLighting.glsl"

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
  
  // PUSH FRAME INTO LINEAR SPACE
  bufferList.tex0.rgb = toLinear(bufferList.tex0.rgb);

  // DRAW SKY
  if(!_getLandMask(positionData.depthBack) && !maskList.weather) bufferList.tex0.rgb = drawSky(positionData.viewBack, SKY_MODE_DRAW);

  // COMPUTE DITHER
  cv(float) ditherScale = pow(32.0, 2.0);
  vec2 dither = vec2(bayer32(gl_FragCoord.xy), ditherScale);

  // CALCULATE ATMOSPHERE LIGHTING
  mat2x3 atmosphereLighting = getAtmosphereLighting();

  // PERFORM SHADING
  if(_getLandMask(positionData.depthBack)) bufferList.tex0.rgb = getShadedSurface(gbufferData, positionData, maskList, bufferList.tex0.rgb, dither, atmosphereLighting, bufferList.tex4);
  
  // POPULATE OUTGOING BUFFERS
  /* DRAWBUFFERS:04 */
  gl_FragData[0] = bufferList.tex0;
  gl_FragData[1] = bufferList.tex4;
}
