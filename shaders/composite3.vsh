/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#version 120

#include "/lib/common/syntax/Shaders.glsl"
#define SHADER VSH
#define PROGRAM COMPOSITE3
#include "/lib/Header.glsl"

// CONST
// USED BUFFERS
// VARYING
varying vec2 screenCoord;

flat(vec4) timeVector;

// UNIFORM
uniform float sunAngle;

// STRUCT
// ARBITRARY
// INCLUDED FILES
#include "/lib/common/util/Time.glsl"

// FUNCTIONS
// MAIN
void main() {
  gl_Position = reprojectVertex(gl_ModelViewMatrix, gl_Vertex.xyz);

  screenCoord = gl_MultiTexCoord0.xy;

  timeVector = getTimeVector();
}
