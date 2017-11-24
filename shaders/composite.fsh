/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#version 120
#extension GL_EXT_gpu_shader4 : enable

#include "/lib/common/syntax/Shaders.glsl"
#define SHADER FSH
#define PROGRAM COMPOSITE0
#include "/lib/Header.glsl"

// CONST
// USED BUFFERS
#define IN_TEX0
#define IN_TEX1
#define IN_TEX2
#define IN_TEX4
#define IN_TEX6

// VARYING
varying vec2 screenCoord;

flat(vec3) sunVector;
flat(vec3) moonVector;
flat(vec3) lightVector;
flat(vec3) wLightVector;

// UNIFORM
uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex4;
uniform sampler2D colortex6;

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
uniform mat4 shadowModelView;

uniform vec3 cameraPosition;

uniform int isEyeInWater;
uniform int worldTime;
uniform int moonPhase;

uniform float near;
uniform float far;
uniform float viewWidth;
uniform float viewHeight;
uniform float rainStrength;
uniform float frameTimeCounter;

uniform ivec2 eyeBrightnessSmooth;

// STRUCT
#include "/lib/common/struct/StructBuffer.glsl"
#include "/lib/common/struct/StructGbuffer.glsl"
#include "/lib/common/struct/StructPosition.glsl"
#include "/lib/common/struct/StructMask.glsl"

// ARBITRARY
// INCLUDED FILES
#include "/lib/common/util/SpaceTransform.glsl"

#include "/lib/common/Atmosphere.glsl"
#include "/lib/common/AtmosphereLighting.glsl"

#include "/lib/common/WaterAbsorption.glsl"

#include "/lib/deferred/VolumetricClouds.glsl"
#include "/lib/deferred/Volumetrics.glsl"

#include "/lib/deferred/Refraction.glsl"

// FUNCTIONS
vec3 getWaterAbsorption(in vec3 colour, io PositionObject position) {
  if(isEyeInWater == 0) return colour;

  float dist = distance(vec3(0.0), position.viewPositionFront);

  return interactWater(colour, dist);
}

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

  // GENERATE ATMOSPHERE LIGHTING
  mat2x3 atmosphereLighting = getAtmosphereLighting();

  // DRAW REFRACTION
  buffers.tex0.rgb = drawRefraction(gbuffer, position, buffers.tex0.rgb, screenCoord);

  // DRAW TRANSPARENT BLOCKS
  buffers.tex0.rgb *= (buffers.tex6.a > 0.0) ? gbuffer.albedo : vec3(1.0);
  buffers.tex0.rgb  = mix(buffers.tex0.rgb, buffers.tex6.rgb, buffers.tex6.a);

  // DRAW UNDERWATER ABSORPTION
  buffers.tex0.rgb = getWaterAbsorption(buffers.tex0.rgb, position);

  // DRAW TRANSPARENT REFLECTIONS
  buffers.tex0.rgb += buffers.tex4.rgb;

  // GENERATE VOLUMETRICS
  buffers.tex4 = getVolumetrics(gbuffer, position, mask, screenCoord, atmosphereLighting);

  // GENERATE VOLUMETRIC CLOUDS
  buffers.tex5 = getVolumetricClouds(position.viewPositionBack, position.depthBack, atmosphereLighting);
  
  // POPULATE OUTGOING BUFFERS
/* DRAWBUFFERS:045 */
  gl_FragData[0] = buffers.tex0;
  gl_FragData[1] = buffers.tex4;
  gl_FragData[2] = buffers.tex5;
}
