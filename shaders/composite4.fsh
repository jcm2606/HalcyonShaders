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
/* USED BUFFER */
#define IN_TEX0

/* VARYING */
varying vec2 screenCoord;

flat(vec4) timeVector;

/* UNIFORM */
uniform sampler2D colortex0;
uniform sampler2D colortex3;

/* GLOBAL */
/* STRUCT */
#include "/lib/struct/Buffers.glsl"

/* INCLUDE */
#include "/lib/deferred/Camera.glsl"

/* FUNCTION */
/* MAIN */
void main() {
  // CREATE STRUCT INSTANCES
  _newBufferList(bufferList);

  // POPULATE STRUCT INSTANCES
  populateBufferList(bufferList, screenCoord);

  // PERFORM CAMERA EXPOSURE
  bufferList.tex0.rgb = getExposedFrame(bufferList.tex0.rgb, screenCoord);

  // POPULATE OUTGOING BUFFERS
  /* DRAWBUFFERS:0 */
  gl_FragData[0] = bufferList.tex0;
}
