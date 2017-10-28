/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#version 120
#extension GL_EXT_gpu_shader4 : enable

#include "/lib/common/syntax/Shaders.glsl"
#define SHADER VSH
#define PROGRAM SHADOW
#include "/lib/Header.glsl"

// CONST
// VARYING
varying mat3 ttn;

varying vec4 colour;

varying vec3 normal;
varying vec3 world;
varying vec3 shadow;

flat(vec2) entity;
varying vec2 uvCoord;

flat(float) objectID;
varying float dist;

// UNIFORM
attribute vec4 mc_Entity;
attribute vec4 at_tangent;

uniform mat4 shadowProjection;
uniform mat4 shadowModelView;
uniform mat4 shadowModelViewInverse;

uniform vec3 cameraPosition;

uniform int isEyeInWater;

// ARBITRARY
// INCLUDED FILES
#include "/lib/common/util/ShadowTransform.glsl"

// FUNCTIONS
// MAIN
void main() {
  colour = gl_Color;

  uvCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
  //lmCoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;

  entity = mc_Entity.xz;
  #include "/lib/gbuffer/ObjectIDs.glsl"

  vec3 position = deprojectVertex(shadowModelViewInverse, gl_ModelViewMatrix, gl_Vertex.xyz);
  world = position + cameraPosition;

  // ADD-IN POINT: Vertex deformation.
  // ADD-IN POINT: Waving terrain.

  gl_Position = reprojectVertex(shadowModelView, position);

  shadow = gl_Position.xyz;

  gl_Position.xy = distortShadowPosition(gl_Position.xy, 0);
  gl_Position.z *= shadowDepthMult;

  ttn = mat3(0.0);

  normal = normalize(gl_NormalMatrix * gl_Normal);

  ttn[0] = normalize(gl_NormalMatrix * at_tangent.xyz);
  ttn[1] = cross(ttn[0], normal);
  ttn[2] = normal;
}
