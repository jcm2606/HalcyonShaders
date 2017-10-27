/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

// CONST
// VARYING
flat(vec2) entity;
varying vec2 uvCoord;
varying vec2 lmCoord;

varying vec3 normal;
varying vec3 vertex;
varying vec3 world;

varying vec4 colour;

varying mat3 ttn;

flat(float) material;
varying float dist;

// UNIFORM
attr(vec4) at_tangent;
attr(vec4) mc_Entity;

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

uniform vec3 cameraPosition;

// ARBITRARY
// INCLUDED FILES
// MAIN
void main() {
  colour = gl_Color;

  entity = mc_Entity.xz;
  //#include "/lib/gbuffer/Materials.glsl"

  uvCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
  lmCoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;

  vec3 position = deprojectVertex(gbufferModelViewInverse, gl_ModelViewMatrix, gl_Vertex.xyz);
  world = position + cameraPosition;

  // ADD-IN POINT: Waving water.

  gl_Position = reprojectVertex(gbufferModelView, position);

  normal = fnormalize(gl_NormalMatrix * gl_Normal);

  vertex = (gl_ModelViewMatrix * gl_Vertex).xyz;

  ttn = mat3(0.0);

  ttn[0] = fnormalize(gl_NormalMatrix * at_tangent.xyz);
  ttn[1] = cross(ttn[0], normal);
  ttn[2] = normal;

  dist = flength(vertex);
}
