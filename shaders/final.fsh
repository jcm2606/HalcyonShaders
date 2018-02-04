/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#version 120

#include "/lib/Header.glsl"
#define PROGRAM FINAL
#define SHADER FSH
#include "/lib/Syntax.glsl"

/* CONST */
/* USED BUFFER */
#define IN_TEX0
#define IN_TEX4

/* VARYING */
varying vec2 screenCoord;

/* UNIFORM */
uniform sampler2D colortex0;
uniform sampler2D colortex4;

uniform float viewWidth;
uniform float viewHeight;

/* GLOBAL */
/* STRUCT */
#include "/lib/struct/Buffers.glsl"

/* INCLUDE */
#include "/lib/final/Tonemap.glsl"

#include "/lib/common/Bloom.glsl"

/* FUNCTION */
/* MAIN */
void main() {
  // CREATE STRUCT INSTANCES
  _newBufferList(bufferList);

  // POPULATE STRUCT INSTANCES
  populateBufferList(bufferList, screenCoord);

  // DRAW BLOOM
  bufferList.tex0.rgb = drawBloom(bufferList.tex0.rgb, screenCoord);
  
  // PERFORM TONEMAPPING
  bufferList.tex0.rgb = tonemap(bufferList.tex0.rgb);

  // CONVERT TO GAMMA SPACE
  bufferList.tex0.rgb = toGamma(bufferList.tex0.rgb);

  // POPULATE OUTGOING BUFFERS
  gl_FragColor = bufferList.tex0;
}
