/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#version 120

#include "/lib/common/syntax/Shaders.glsl"
#define SHADER VSH
#define PROGRAM DEFERRED0
#include "/lib/Header.glsl"

// CONST
// USED BUFFERS
// VARYING
varying vec2 screenCoord;

flat(vec3) sunVector;
flat(vec3) moonVector;

// UNIFORM
uniform vec3 sunPosition;

// STRUCT
// ARBITRARY
// INCLUDED FILES
// FUNCTIONS
// MAIN
void main() {
  gl_Position = reprojectVertex(gl_ModelViewMatrix, gl_Vertex.xyz);

  screenCoord = gl_MultiTexCoord0.xy;

  getSunVector();
  getMoonVector();
}
