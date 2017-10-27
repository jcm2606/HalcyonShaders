/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#version 120
#extension GL_EXT_gpu_shader4 : enable

#include "/lib/common/syntax/Shaders.glsl"
#define SHADER FSH
#define PROGRAM COMPOSITE4
#include "/lib/Header.glsl"

// CONST
// USED BUFFERS
// VARYING
varying vec2 screenCoord;

// UNIFORM
uniform sampler2D colortex0;

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

  // GENERATE BLOOM TILES
  // POPULATE OUTGOING BUFFERS
/* DRAWBUFFERS:4 */
  gl_FragData[0] = buffers.tex4;
}
