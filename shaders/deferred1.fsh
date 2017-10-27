/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#version 120
#extension GL_EXT_gpu_shader4 : enable

#include "/lib/common/syntax/Shaders.glsl"
#define SHADER FSH
#define PROGRAM DEFERRED1
#include "/lib/Header.glsl"

// CONST
// USED BUFFERS
#define IN_TEX0
#define IN_TEX1
#define IN_TEX2

// VARYING
varying vec2 screenCoord;

// UNIFORM
uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;

// STRUCT
#include "/lib/common/struct/StructBuffer.glsl"
#include "/lib/common/struct/StructGbuffer.glsl"

// ARBITRARY
// INCLUDED FILES
// FUNCTIONS
// MAIN
void main() {
  // CREATE STRUCTS
  NewBufferObject(buffers);
  NewGbufferObject(gbuffer);

  // POPULATE STRUCTS
  populateBufferObject(buffers, screenCoord);
  populateGbufferObject(gbuffer, buffers);

  // CONVERT FRAME TO LINEAR SPACE
  buffers.tex0.rgb = toLinear(buffers.tex0.rgb);

  // DRAW SKY
  // PERFORM SHADING
  // POPULATE OUTGOING BUFFERS
/* DRAWBUFFERS:0 */
  gl_FragData[0] = buffers.tex0;
}
