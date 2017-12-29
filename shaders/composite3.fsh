/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#version 120

#include "/lib/common/syntax/Shaders.glsl"
#define SHADER FSH
#define PROGRAM COMPOSITE3
#include "/lib/Header.glsl"

// CONST
const bool colortex0MipmapEnabled = true;

// USED BUFFERS
#define IN_TEX0
#define IN_TEX3

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

  //buffers.tex0.rgb = vec3(buffers.tex3.a);

  //buffers.tex0.rgb = vec3(readFromTile(colortex3, TILE_TEMPORAL_AVERAGE_LUMA, 5).a);

  // POPULATE OUTGOING BUFFERS
/* DRAWBUFFERS:0 */
  gl_FragData[0] = buffers.tex0;
}
