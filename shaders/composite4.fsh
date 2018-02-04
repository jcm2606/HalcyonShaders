/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#version 120

#include "/lib/Header.glsl"
#define PROGRAM COMPOSITE4
#define SHADER FSH
#include "/lib/Syntax.glsl"

/* CONST */
const bool colortex0MipmapEnabled = true;

/* USED BUFFER */
/* VARYING */
varying vec2 screenCoord;

/* UNIFORM */
uniform sampler2D colortex0;

uniform float viewWidth;
uniform float viewHeight;
uniform float aspectRatio;

/* GLOBAL */
/* STRUCT */
#include "/lib/struct/Buffers.glsl"

/* INCLUDE */
#include "/lib/common/Bloom.glsl"

/* FUNCTION */
/* MAIN */
void main() {
  // CREATE STRUCT INSTANCES
  _newBufferList(bufferList);

  // POPULATE STRUCT INSTANCES
  populateBufferList(bufferList, screenCoord);

  // COMPUTE BLOOM TILES
  bufferList.tex4.rgb = computeBloomTiles(screenCoord);

  // POPULATE OUTGOING BUFFERS
  /* DRAWBUFFERS:4 */
  gl_FragData[0] = bufferList.tex4;
}
