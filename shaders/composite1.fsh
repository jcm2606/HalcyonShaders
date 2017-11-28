/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#version 120
#extension GL_EXT_gpu_shader4 : enable

#include "/lib/common/syntax/Shaders.glsl"
#define SHADER FSH
#define PROGRAM COMPOSITE1
#include "/lib/Header.glsl"

// CONST
const bool colortex4MipmapEnabled = true;
const bool colortex5MipmapEnabled = true;

// USED BUFFERS
#define IN_TEX0
#define IN_TEX1
#define IN_TEX2
#define IN_TEX5

// VARYING
varying vec2 screenCoord;

// UNIFORM
uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex4;
uniform sampler2D colortex5;

uniform sampler2D depthtex0;
uniform sampler2D depthtex1;

uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

uniform int isEyeInWater;

// STRUCT
#include "/lib/common/struct/StructBuffer.glsl"
#include "/lib/common/struct/StructGbuffer.glsl"
#include "/lib/common/struct/StructPosition.glsl"

// ARBITRARY
// INCLUDED FILES
#include "/lib/common/util/SpaceTransform.glsl"

#include "/lib/deferred/Volumetrics.glsl"
#include "/lib/deferred/VolumetricClouds.glsl"

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

  // DRAW VOLUMETRIC CLOUDS
  buffers.tex0.rgb = drawVolumetricClouds(position, buffers.tex0.rgb, screenCoord);

  // DRAW VOLUMETRICS
  buffers.tex0.rgb = drawVolumetrics(gbuffer, position, buffers.tex0.rgb, screenCoord);

  // POPULATE OUTGOING BUFFERS
/* DRAWBUFFERS:0 */
  gl_FragData[0] = buffers.tex0;
}
