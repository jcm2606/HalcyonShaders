/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#version 120

#include "/lib/common/syntax/Shaders.glsl"
#define SHADER FSH
#define PROGRAM COMPOSITE2
#include "/lib/Header.glsl"

// CONST
const bool colortex0MipmapEnabled = true;

// USED BUFFERS
#define IN_TEX0

// VARYING
varying vec2 screenCoord;

flat(vec4) timeVector;

// UNIFORM
uniform sampler2D colortex0;
uniform sampler2D colortex3;

uniform float frameTime;

// STRUCT
#include "/lib/common/struct/StructBuffer.glsl"

// ARBITRARY
// INCLUDED FILES
#include "/lib/deferred/Camera.glsl"

// FUNCTIONS
// MAIN
void main() {
  // CREATE STRUCTS
  NewBufferObject(buffers);

  // POPULATE STRUCTS
  populateBufferObject(buffers, screenCoord);

  // PERFORM CAMERA EXPOSURE
  buffers.tex0.rgb = getExposedFrame(buffers.tex3.a, buffers.tex0.rgb, screenCoord);

  // POPULATE OUTGOING BUFFERS
/* DRAWBUFFERS:03 */
  gl_FragData[0] = buffers.tex0;
  gl_FragData[1] = buffers.tex3;
}
