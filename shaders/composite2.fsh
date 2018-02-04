/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#version 120

#include "/lib/Header.glsl"
#define PROGRAM COMPOSITE2
#define SHADER FSH
#include "/lib/Syntax.glsl"

/* CONST */
const bool colortex0MipmapEnabled = true;

/* USED BUFFER */
#define IN_TEX0
#define IN_TEX3

/* VARYING */
varying vec2 screenCoord;

/* UNIFORM */
uniform sampler2D colortex0;
uniform sampler2D colortex3;

uniform sampler2D depthtex1;

uniform float frameTime;

/* GLOBAL */
/* STRUCT */
#include "/lib/struct/Buffers.glsl"

/* INCLUDE */
#include "/lib/deferred/Temporal.glsl"

/* FUNCTION */
/* MAIN */
void main() {
  // CREATE STRUCT INSTANCES
  _newBufferList(bufferList);

  // POPULATE STRUCT INSTANCES
  populateBufferList(bufferList, screenCoord);

  // PERFORM TEMPORAL SMOOTHING
  getTemporalSmoothing(bufferList.tex3.a, screenCoord);

  // POPULATE OUTGOING BUFFERS
  /* DRAWBUFFERS:03 */
  gl_FragData[0] = bufferList.tex0;
  gl_FragData[1] = bufferList.tex3;
}
