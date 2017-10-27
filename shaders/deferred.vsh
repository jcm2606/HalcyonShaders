/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#version 120
#extension GL_EXT_gpu_shader4 : enable

#include "/lib/common/syntax/Shaders.glsl"
#define SHADER VSH
#define PROGRAM DEFERRED0
#include "/lib/Header.glsl"

// CONST
// USED BUFFERS
// VARYING
varying vec2 screenCoord;

// UNIFORM
// STRUCT
// ARBITRARY
// INCLUDED FILES
// FUNCTIONS
// MAIN
void main() {
  gl_Position = reprojectVertex(gl_ModelViewMatrix, gl_Vertex.xyz);

  screenCoord = gl_MultiTexCoord0.xy;
}
