/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#version 120
#extension GL_EXT_gpu_shader4 : enable

#include "/lib/common/syntax/Shaders.glsl"
#define SHADER FSH
#define PROGRAM SHADOW
#include "/lib/Header.glsl"

// CONST
// VARYING
varying mat3 ttn;

varying vec4 colour;

varying vec3 world;
varying vec3 shadow;

flat(vec2) entity;
varying vec2 uvCoord;

flat(float) objectID;
varying float dist;

// UNIFORM
uniform sampler2D texture;

// ARBITRARY
// INCLUDED FILES
// FUNCTIONS
// MAIN
void main() {
  vec4 albedo = texture2D(texture, uvCoord) * colour;

  gl_FragData[0] = albedo;
}
