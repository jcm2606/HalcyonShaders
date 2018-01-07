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

// UNIFORM
uniform sampler2D colortex0;
uniform sampler2D colortex3;

uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D depthtex2;

uniform float viewWidth;
uniform float viewHeight;

// STRUCT
#include "/lib/common/struct/StructBuffer.glsl"
#include "/lib/common/struct/StructPosition.glsl"

// ARBITRARY
// INCLUDED FILES
#include "/lib/deferred/DOF.glsl"

// FUNCTIONS
// MAIN
void main() {
  // CREATE STRUCTS
  NewBufferObject(buffers);
  NewPositionObject(position);

  // POPULATE STRUCTS
  populateBufferObject(buffers, screenCoord);
  populateDepths(position, screenCoord);

  // DRAW DEPTH-OF-FIELD
  buffers.tex0.rgb = drawDOF(position, buffers.tex0.rgb, screenCoord, readFromTile(colortex3, TILE_TEMPORAL_CENTER_DEPTH, 5).a);

  // POPULATE OUTGOING BUFFERS
/* DRAWBUFFERS:0 */
  gl_FragData[0] = buffers.tex0;
}
