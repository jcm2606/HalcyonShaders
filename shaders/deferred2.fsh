/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#version 120
#extension GL_EXT_gpu_shader4 : enable

#include "/lib/common/syntax/Shaders.glsl"
#define SHADER FSH
#define PROGRAM DEFERRED2
#include "/lib/Header.glsl"

// CONST
// USED BUFFERS
#define IN_TEX0
#define IN_TEX1
#define IN_TEX2
#define IN_TEX5

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
uniform sampler2D colortex5;

uniform sampler2D depthtex0;
uniform sampler2D depthtex1;

uniform sampler2D noisetex;

uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

uniform int isEyeInWater;
uniform int worldTime;
uniform int moonPhase;

uniform vec3 cameraPosition;

uniform float near;
uniform float far;
uniform float rainStrength;
uniform float frameTimeCounter;

// STRUCT
#include "/lib/common/struct/StructBuffer.glsl"
#include "/lib/common/struct/StructGbuffer.glsl"
#include "/lib/common/struct/StructPosition.glsl"

// ARBITRARY
// INCLUDED FILES
#include "/lib/deferred/VolumetricClouds.glsl"

#include "/lib/common/Reflections.glsl"

// FUNCTIONS
// MAIN
void main() {
  // CREATE STRUCTS
  NewBufferObject(buffers);
  NewGbufferObject(gbuffer);
  NewPositionObject(position);

  // POPULATE STRUCTS
  populateBufferObject(buffers, screenCoord);
  populateGbufferObject(gbuffer, buffers);
  populateDepths(position, screenCoord);
  populateViewPositions(position, screenCoord);

  // DRAW REFLECTIONS
  buffers.tex0.rgb = (getLandMask(position.depthBack)) ? drawReflectionOnSurface(buffers.tex0, colortex0, position.viewPositionBack, getAtmosphereLighting(), gbuffer.albedo, gbuffer.normal, gbuffer.roughness, gbuffer.f0, buffers.tex5, gbuffer.skyLight) : buffers.tex0.rgb;

  // POPULATE OUTGOING BUFFERS
/* DRAWBUFFERS:07 */
  gl_FragData[0] = buffers.tex0;
  gl_FragData[1] = buffers.tex0;
}
