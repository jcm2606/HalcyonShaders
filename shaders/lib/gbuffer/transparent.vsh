/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

/* CONST */
/* VARYING */
varying vec2 uvCoord;
varying vec2 lightmap;

varying vec4 colour;

varying vec3 view;
varying vec3 world;

varying mat3 ttn;

flat(vec2) entity;
flat(float) objectID;

varying float dist;

/* ATTRIBUTE */
attribute vec4 mc_Entity;
attribute vec4 at_tangent;
attribute vec4 mc_midTexCoord;

/* UNIFORM */
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

uniform vec3 cameraPosition;

/* GLOBAL */
/* STRUCT */
/* INCLUDE */
#include "/lib/gbuffer/ObjectID.glsl"

/* FUNCTION */
/* MAIN */
void main() {
  uvCoord = gl_MultiTexCoord0.xy;
  lightmap = _pow((gl_TextureMatrix[1] * gl_MultiTexCoord1).xy, 2.0);

  colour = gl_Color;

  entity = mc_Entity.xz;
  objectID = getObjectID(entity);

  view = _transMAD(gl_ModelViewMatrix, gl_Vertex.xyz);
  world = _transMAD(gbufferModelViewInverse, view) + cameraPosition;

  gl_Position = _transMAD(gbufferModelView, world - cameraPosition).xyzz * _diagonal4(gl_ProjectionMatrix) + gl_ProjectionMatrix[3];

  vec3 normal = normalize(gl_NormalMatrix * gl_Normal);

  ttn    = mat3(0.0);
  ttn[0] = normalize(gl_NormalMatrix * at_tangent.xyz * sign(at_tangent.w));
  ttn[1] = cross(ttn[0], normal);
  ttn[2] = normal;
}
