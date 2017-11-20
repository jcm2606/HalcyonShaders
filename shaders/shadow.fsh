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

uniform sampler2D noisetex;

uniform float frameTimeCounter;

// ARBITRARY
// INCLUDED FILES
#include "/lib/common/TransparentNormals.glsl"

// FUNCTIONS
// MAIN
void main() {
  vec4 albedo = texture2D(texture, uvCoord) * colour;
  
  // GENERATE OBJECT MASKS
  bool water = (entity.x == WATER.x || entity.y == WATER.y);

  if(water) {
    vec3 customNormal = getNormal(world, objectID);

    #if 0
      vec3 nworld = normalize(world);
      vec3 refractPos = refract(nworld, customNormal, refractInterfaceAirWater);
      float caustic = pow(( flength(dFdx(nworld)) * flength(dFdy(nworld)) ) / ( flength(dFdx(refractPos)) * flength(dFdy(refractPos)) ), 0.125);
    #else
      float caustic = mix(0.9, 1.1, pow2(1.0 - customNormal.z));
    #endif

    albedo.rgb = vec3(caustic);
  }

/* DRAWBUFFERS:01 */
  gl_FragData[0] = toShadowLDR(albedo);
  gl_FragData[1] = vec4(vec3(0.0), objectID * objectIDRangeRCP);
}
