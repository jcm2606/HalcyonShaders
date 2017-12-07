/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#version 120

#include "/lib/common/syntax/Shaders.glsl"
#define SHADER FSH
#define PROGRAM DEFERRED0
#include "/lib/Header.glsl"

// CONST
// USED BUFFERS
#define IN_TEX1
#define IN_TEX2

// VARYING
varying vec2 screenCoord;

flat(vec3) sunVector;
flat(vec3) moonVector;

// UNIFORM
uniform sampler2D colortex1;
uniform sampler2D colortex2;

uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D depthtex2;

uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

uniform vec3 sunPosition;
uniform vec3 cameraPosition;

uniform int isEyeInWater;

uniform float viewWidth;
uniform float viewHeight;
uniform float near;
uniform float far;

// STRUCT
#include "/lib/common/struct/StructBuffer.glsl"
#include "/lib/common/struct/StructGbuffer.glsl"
#include "/lib/common/struct/StructPosition.glsl"

// ARBITRARY
// INCLUDED FILES
#include "/lib/common/util/SpaceTransform.glsl"

#include "/lib/forward/AmbientLight.glsl"

// FUNCTIONS
// MAIN
void main() {
  // CREATE STRUCTS
  NewBufferObject(buffers);
  NewGbufferObject(gbuffer);
  NewPositionObject(position);

  // POPULATE STRUCTS
  populateBufferObject(buffers, screenCoord);
  populateGbufferObject(gbuffer, buffers);
  populateDepths(position, screenCoord);
  populateViewPositions(position, screenCoord);

  // GENERATE AMBIENT LIGHT
  buffers.tex4.rgb  = getAmbientDiffuse(gbuffer, position, screenCoord);
  
  // POPULATE OUTGOING BUFFERS
/* DRAWBUFFERS:4 */
  gl_FragData[0] = buffers.tex4;
}
