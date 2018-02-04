/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#version 120

#include "/lib/Header.glsl"
#define PROGRAM FINAL
#define SHADER VSH
#include "/lib/Syntax.glsl"

/* CONST */
/* VARYING */
varying vec2 screenCoord;

/* UNIFORM */
/* GLOBAL */
/* STRUCT */
/* INCLUDE */
/* FUNCTION */
/* MAIN */
void main() {
  gl_Position = ftransform();

  screenCoord = gl_MultiTexCoord0.xy;
}
