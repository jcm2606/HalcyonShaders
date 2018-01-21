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

/* UNIFORM */
uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex4;

uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D depthtex2;

uniform mat4 gbufferProjection, gbufferProjectionInverse;
uniform mat4 gbufferModelView, gbufferModelViewInverse;

uniform int isEyeInWater;

uniform float sunAngle;
uniform float near;
uniform float far;

/* GLOBAL */
/* STRUCT */
#include "/lib/struct/Buffers.glsl"
#include "/lib/struct/Gbuffer.glsl"
#include "/lib/struct/Mask.glsl"
#include "/lib/struct/Position.glsl"

/* INCLUDE */
#include "/lib/common/Reflections.glsl"

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
  #ifdef SPECULAR_DUAL_LAYER
    populateGbufferData(gbufferData, bufferList);
    populateMaskList(maskList, gbufferData);
    populateDepths(positionData, screenCoord);
    populateViewPositions(positionData, screenCoord);

    // COMPUTE DITHER
    cv(float) ditherScale = pow(128.0, 2.0);
    vec2 dither = vec2(bayer128(gl_FragCoord.xy), ditherScale);

    // DRAW REFLECTIONS
    if(_getLandMask(positionData.depthBack)) bufferList.tex0.rgb = drawReflections(gbufferData, positionData, bufferList.tex0.rgb, screenCoord, getAtmosphereLighting(), bufferList.tex4, dither);
  #endif

  //bufferList.tex0.rgb = vec3(gbufferData.f0);

  // POPULATE OUTGOING BUFFERS
  /* DRAWBUFFERS:0 */
  gl_FragData[0] = bufferList.tex0;
}
