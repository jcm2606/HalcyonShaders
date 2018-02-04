/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

/* CONST */
/* VARYING */
varying vec2 screenCoord;

flat(vec3) sunDirection;
flat(vec3) moonDirection;
flat(vec3) lightDirection;
flat(vec3) wLightDirection;

flat(vec4) timeVector;

/* UNIFORM */
uniform mat4 gbufferModelViewInverse;

uniform vec3 sunPosition;
uniform vec3 shadowLightPosition;

uniform float sunAngle;

/* GLOBAL */
/* STRUCT */
/* INCLUDE */
#include "/lib/util/Time.glsl"

/* FUNCTION */
/* MAIN */
void main() {
  gl_Position = ftransform();

  screenCoord = gl_MultiTexCoord0.xy;

  _getSunDirection();
  _getMoonDirection();
  _getLightDirection();
  _getWorldLightDirection();

  getTimeVector(timeVector);
}
