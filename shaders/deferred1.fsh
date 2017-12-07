/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#version 120

#include "/lib/common/syntax/Shaders.glsl"
#define SHADER FSH
#define PROGRAM DEFERRED1
#include "/lib/Header.glsl"

// CONST
const bool shadowtex0Mipmap = true;
const bool shadowtex1Mipmap = true;
const bool shadowcolor0Mipmap = true;
const bool shadowcolor1Mipmap = true;

const bool colortex4MipmapEnabled = true;

// USED BUFFERS
#define IN_TEX0
#define IN_TEX1
#define IN_TEX2

// VARYING
varying vec2 screenCoord;

flat(vec3) sunVector;
flat(vec3) moonVector;
flat(vec3) lightVector;
flat(vec3) wLightVector;

flat(vec4) timeVector;

// UNIFORM
uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex4;

uniform sampler2D depthtex0;
uniform sampler2D depthtex1;

uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;
uniform sampler2D shadowcolor1;

uniform sampler2D noisetex;

uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

uniform mat4 shadowProjection;
uniform mat4 shadowProjectionInverse;
uniform mat4 shadowModelView;

uniform int isEyeInWater;
uniform int worldTime;
uniform int moonPhase;

uniform float near;
uniform float far;
uniform float viewWidth;
uniform float viewHeight;
uniform float rainStrength;
uniform float frameTimeCounter;

uniform vec3 cameraPosition;

// STRUCT
#include "/lib/common/struct/StructBuffer.glsl"
#include "/lib/common/struct/StructGbuffer.glsl"
#include "/lib/common/struct/StructPosition.glsl"
#include "/lib/common/struct/StructMask.glsl"

// ARBITRARY
// INCLUDED FILES
#include "/lib/common/util/SpaceTransform.glsl"
#include "/lib/common/util/ShadowTransform.glsl"

#include "/lib/common/Sky.glsl"
#include "/lib/common/AtmosphereLighting.glsl"

#include "/lib/common/VolumetricClouds.glsl"

#include "/lib/forward/Shading.glsl"

// FUNCTIONS
// MAIN
void main() {
  // CREATE STRUCTS
  NewBufferObject(buffers);
  NewGbufferObject(gbuffer);
  NewPositionObject(position);
  NewMaskObject(mask);

  // POPULATE STRUCTS
  populateBufferObject(buffers, screenCoord);
  populateGbufferObject(gbuffer, buffers);
  populateDepths(position, screenCoord);
  populateViewPositions(position, screenCoord);
  populateMaskObject(mask, gbuffer);

  // CONVERT FRAME TO LINEAR SPACE
  buffers.tex0.rgb = toLinear(buffers.tex0.rgb);

  // DRAW SKY
  buffers.tex0.rgb = (!getLandMask(position.depthBack) && !mask.weather) ? drawSky(position.viewBack, 0) : buffers.tex0.rgb;

  // CALCULATE ATMOSPHERE LIGHTING
  mat2x3 atmosphereLighting = getAtmosphereLighting();

  // PERFORM SHADING
  vec4 highlightTint = vec4(0.0);
  buffers.tex0.rgb = (getLandMask(position.depthBack)) ? getFinalShading(highlightTint, gbuffer, mask, position, screenCoord, buffers.tex0.rgb, atmosphereLighting) : buffers.tex0.rgb;
  buffers.tex5 = highlightTint;
  
  // POPULATE OUTGOING BUFFERS
/* DRAWBUFFERS:054 */
  gl_FragData[0] = buffers.tex0;
  gl_FragData[1] = buffers.tex5;
}
