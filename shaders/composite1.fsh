/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#version 120

#include "/lib/Header.glsl"
#define PROGRAM COMPOSITE1
#define SHADER FSH
#include "/lib/Syntax.glsl"

/* CONST */
const bool colortex0MipmapEnabled = true;

const bool colortex4MipmapEnabled = true;
const bool colortex5MipmapEnabled = true;
const bool colortex6MipmapEnabled = true;
const bool colortex7MipmapEnabled = true;

/* USED BUFFER */
#define IN_TEX0
#define IN_TEX1
#define IN_TEX2
#define IN_TEX3
#define IN_TEX4
#define IN_TEX5
#define IN_TEX6

/* VARYING */
varying vec2 screenCoord;

flat(vec3) sunDirection;
flat(vec3) moonDirection;
flat(vec3) lightDirection;

/* UNIFORM */
uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex3;
uniform sampler2D colortex4;
uniform sampler2D colortex5;
uniform sampler2D colortex6;
uniform sampler2D colortex7;

uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D depthtex2;

uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

uniform int isEyeInWater;

uniform float sunAngle;
uniform float near;
uniform float far;
uniform float frameTime;
uniform float viewWidth;
uniform float aspectRatio;

/* GLOBAL */
/* STRUCT */
#include "/lib/struct/Buffers.glsl"
#include "/lib/struct/Gbuffer.glsl"
#include "/lib/struct/Mask.glsl"
#include "/lib/struct/Position.glsl"

/* INCLUDE */
#include "/lib/deferred/Volumetrics.glsl"

#include "/lib/deferred/Temporal.glsl"

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

  // DRAW VOLUMETRIC EFFECTS & TRANSPARENT REFLECTIONS
  bufferList.tex0.rgb = drawVolumetricEffects(gbufferData, positionData, bufferList, bufferList.tex0.rgb, screenCoord, getAtmosphereLighting(), bufferList.tex4.a, dither);

  // PERFORM TEMPORAL SMOOTHING
  getTemporalSmoothing(bufferList.tex3.a, screenCoord);

  // POPULATE OUTGOING BUFFERS
  /* DRAWBUFFERS:03 */
  gl_FragData[0] = bufferList.tex0;
  gl_FragData[1] = bufferList.tex3;
}
