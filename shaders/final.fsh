/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#version 120
#extension GL_EXT_gpu_shader4 : enable

#include "/lib/common/syntax/Shaders.glsl"
#define SHADER FSH
#define PROGRAM FINAL
#include "/lib/Header.glsl"

// CONST
// USED BUFFERS
#define IN_TEX0

// VARYING
varying vec2 screenCoord;

// UNIFORM
uniform sampler2D colortex0;

// STRUCT
#include "/lib/common/struct/StructBuffer.glsl"

// ARBITRARY
// INCLUDED FILES
#include "/lib/final/Tonemapping.glsl"

// FUNCTIONS
// MAIN
void main() {
  // CREATE STRUCTS
  NewBufferObject(buffers);

  // POPULATE STRUCTS
  populateBufferObject(buffers, screenCoord);

  // DRAW BLOOM
  // PERFORM TONEMAPPING
  buffers.tex0.rgb = tonemap(buffers.tex0.rgb);

  // CONVERT FRAME TO GAMMA SPACE
  buffers.tex0.rgb = toGamma(buffers.tex0.rgb);

  // POPULATE OUTGOING BUFFERS
  gl_FragColor = buffers.tex0;
}
