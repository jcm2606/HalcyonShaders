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
    albedo = vec4(1.0);

    vec3 normal = getNormal(world, objectID);

    cv(float) normalAnisotropy = 0.3;
    normal = normal * vec3(normalAnisotropy) + vec3(0.0, 0.0, 1.0 - normalAnisotropy);

    float caustic = 1.0 - pow(1.0 - normal.z, 1.0 / 24.0);
          //caustic = ceil(_max0(_pow(caustic, 1.0e4) - 0.1));

    albedo.rgb = vec3(mix(0.2, 1.0, saturate(caustic)));
  }

  gl_FragData[0] = toLDR(albedo, dynamicRangeShadow);
  gl_FragData[1] = vec4(vec3(0.0), float(isWater));
}
