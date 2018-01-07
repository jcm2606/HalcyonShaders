/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#version 120

#include "/lib/common/syntax/Shaders.glsl"
#define SHADER FSH
#define PROGRAM COMPOSITE0
#include "/lib/Header.glsl"

// CONST
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

#include "/lib/common/VolumetricClouds.glsl"
#include "/lib/deferred/Volumetrics.glsl"

// FUNCTIONS
vec3 getWaterAbsorption(io PositionObject position, io MaskObject mask, in vec3 colour) {
  if(isEyeInWater == 0 && !mask.water) return colour;

  float dist = distance((isEyeInWater == 0) ? position.viewBack : vec3(0.0), position.viewFront);

  return colour * absorbWater(dist);
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

  // DRAW WATER ABSORPTION
  buffers.tex0.rgb = getWaterAbsorption(position, mask, buffers.tex0.rgb);

  // GENERATE VOLUMETRIC CLOUDS
  buffers.tex5 = getVolumetricClouds(gbuffer, position, atmosphereLighting);

  // GENERATE VOLUMETRICS
  float frontAbsorption = 0.0;
  buffers.tex4 = getVolumetrics(gbuffer, position, mask, frontAbsorption, screenCoord, atmosphereLighting);

  // WRITE FRONT TRANSMITTANCE TO TEX0 A
  buffers.tex0.a = frontAbsorption;
  
  // POPULATE OUTGOING BUFFERS
/* DRAWBUFFERS:045 */
  gl_FragData[0] = buffers.tex0;
  gl_FragData[1] = buffers.tex4;
  gl_FragData[2] = buffers.tex5;
}
