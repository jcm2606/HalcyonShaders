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
#define IN_TEX4

// VARYING
varying vec2 screenCoord;

// UNIFORM
uniform sampler2D colortex0;
uniform sampler2D colortex4;

// STRUCT
#include "/lib/common/struct/StructBuffer.glsl"

// ARBITRARY
// INCLUDED FILES
// FUNCTIONS
// MAIN
void main() {
  // CREATE STRUCTS
  NewBufferObject(buffers);

  // POPULATE STRUCTS
  populateBufferObject(buffers, screenCoord);

  // GENERATE VOLUMETRICS
  // GENERATE VOLUMETRIC CLOUDS
  // DRAW TRANSPARENT ALBEDO
  buffers.tex0.rgb  = 

  // DRAW TRANSPARENT REFLECTIONS
  buffers.tex0.rgb += buffers.tex4.rgb;

  // POPULATE OUTGOING BUFFERS
/* DRAWBUFFERS:045 */
  gl_FragData[0] = buffers.tex0;
  gl_FragData[1] = buffers.tex4;
  gl_FragData[2] = buffers.tex5;
}
