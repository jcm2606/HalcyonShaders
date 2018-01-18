/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

/* CONST */
/* VARYING */
varying vec2 uvCoord;

varying vec4 colour;

varying vec3 view;
varying vec3 world;
varying vec3 shadow;

flat(vec2) entity;
flat(float) objectID;

/* ATTRIBUTE */
attribute vec4 mc_Entity;

/* UNIFORM */
uniform mat4 shadowProjection;
uniform mat4 shadowModelView;
uniform mat4 shadowModelViewInverse;

uniform vec3 cameraPosition;

/* GLOBAL */
/* STRUCT */
/* INCLUDE */
#include "/lib/gbuffer/ObjectID.glsl"

#include "/lib/util/ShadowConversion.glsl"

/* FUNCTION */
/* MAIN */
void main() {
  uvCoord = gl_MultiTexCoord0.xy;

  colour = gl_Color;

  entity = mc_Entity.xz;
  objectID = getObjectID(entity);

  view = _transMAD(gl_ModelViewMatrix, gl_Vertex.xyz);
  world = _transMAD(shadowModelViewInverse, view) + cameraPosition;

  gl_Position = _transMAD(shadowModelView, world - cameraPosition).xyzz * _diagonal4(gl_ProjectionMatrix) + gl_ProjectionMatrix[3];

  shadow = gl_Position.xyz;

  gl_Position.xy = distortShadowPosition(gl_Position.xy, false);
  gl_Position.z *= shadowDepthMult;
}
