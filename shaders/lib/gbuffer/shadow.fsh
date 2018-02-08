/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

/* CONST */
/* VARYING */
varying vec2 uvCoord;

varying vec4 colour;

varying vec3 vertex;
varying vec3 view;
varying vec3 world;
varying vec3 shadow;

flat(vec2) entity;
flat(float) objectID;
flat(mat3) ttn;

/* UNIFORM */
uniform sampler2D texture;

uniform sampler2D noisetex;

uniform float frameTimeCounter;
uniform float rainStrength;

/* GLOBAL */
/* STRUCT */
/* INCLUDE */
#include "/lib/common/Normals.glsl"

/* FUNCTION */
/* MAIN */
void main() {
  vec4 albedo = texture2D(texture, uvCoord) * colour;

  bool isWater = compare(objectID, OBJECT_WATER);

  if(isWater) {
    vec3 normal = getNormal(world, OBJECT_WATER);

    float caustic = 0.0;

    caustic = 1.0 - pow(1.0 - normal.z, 1.0 / 3.0);
    caustic = pow(caustic, 8.0) * 2.0;

    albedo = vec4(vec3(caustic), 1.0);
    //albedo = vec4(1.0);
  }

  gl_FragData[0] = vec4(toLDR(albedo.rgb, dynamicRangeShadowRCP), albedo.a);
  gl_FragData[1] = vec4(vec3(0.0), float(isWater));
}
