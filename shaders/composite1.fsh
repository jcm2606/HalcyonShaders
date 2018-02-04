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
const bool colortex4MipmapEnabled = true;
const bool colortex5MipmapEnabled = true;
const bool colortex6MipmapEnabled = true;
const bool colortex7MipmapEnabled = true;

/* USED BUFFER */
#define IN_TEX0
#define IN_TEX1
#define IN_TEX2
#define IN_TEX4
#define IN_TEX5
#define IN_TEX6
#define IN_TEX7

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
uniform sampler2D colortex6;
uniform sampler2D colortex7;

uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D depthtex2;

uniform mat4 gbufferProjection, gbufferProjectionInverse;
uniform mat4 gbufferModelView, gbufferModelViewInverse;

uniform vec3 cameraPosition;
uniform vec3 sunPosition;

uniform int isEyeInWater;

uniform float sunAngle;
uniform float near;
uniform float far;
uniform float frameTime;
uniform float viewWidth;
uniform float viewHeight;
uniform float aspectRatio;

/* GLOBAL */
/* STRUCT */
#include "/lib/struct/Buffers.glsl"
#include "/lib/struct/Gbuffer.glsl"
#include "/lib/struct/Mask.glsl"
#include "/lib/struct/Position.glsl"

/* INCLUDE */
#include "/lib/deferred/Volumetrics.glsl"

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
  cv(float) ditherScale = pow(16.0, 2.0);
  vec2 dither = vec2(bayer16(gl_FragCoord.xy * 4.0), ditherScale);

  // DRAW VOLUMETRIC EFFECTS & TRANSPARENT REFLECTIONS
  bufferList.tex0.rgb = drawVolumetricEffects(gbufferData, positionData, bufferList, maskList, bufferList.tex0.rgb, screenCoord, getAtmosphereLighting(), bufferList.tex4.a, dither);
  
  // POPULATE OUTGOING BUFFERS
  /* DRAWBUFFERS:0 */
  gl_FragData[0] = bufferList.tex0;
}
