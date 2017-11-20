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
const bool colortex4MipmapEnabled = true;

// USED BUFFERS
#define IN_TEX0
#define IN_TEX4

// VARYING
varying vec2 screenCoord;

// UNIFORM
uniform sampler2D colortex0;
uniform sampler2D colortex4;

uniform float viewWidth;
uniform float viewHeight;

// STRUCT
#include "/lib/common/struct/StructBuffer.glsl"

// ARBITRARY
// INCLUDED FILES
#include "/lib/common/Debugging.glsl"

#include "/lib/final/Tonemapping.glsl"

#include "/lib/common/Bloom.glsl"

// FUNCTIONS
// MAIN
void main() {
  // CREATE STRUCTS
  NewBufferObject(buffers);

  // POPULATE STRUCTS
  populateBufferObject(buffers, screenCoord);

  // DRAW BLOOM
  buffers.tex0.rgb = drawBloom(buffers.tex0.rgb, screenCoord);

  // (DEBUGGING) VISUALISE HDR SLICES
  buffers.tex0.rgb = getHDRSlices(buffers.tex0.rgb, screenCoord);

  // PERFORM TONEMAPPING
  buffers.tex0.rgb = tonemap(buffers.tex0.rgb);

  // CONVERT FRAME TO GAMMA SPACE
  buffers.tex0.rgb = toGamma(buffers.tex0.rgb);

  // POPULATE OUTGOING BUFFERS
  gl_FragColor = buffers.tex0;
}
