/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_GBUFFER_DIRECTIONALLIGHTING
  #define INTERNAL_INCLUDED_GBUFFER_DIRECTIONALLIGHTING

  vec2 getDirectionalLightmaps(in vec2 lightmap, in vec3 normal, in vec3 view, in float roughness) {
    vec2 shading = lightmap;

    #define blockShading shading.x
    #define skyShading shading.y

    mat2 derivatives = mat2(
      vec2(dFdx(blockShading), dFdy(blockShading)) * 256.0,
      vec2(dFdx(skyShading), dFdy(skyShading)) * 256.0
    );

    #define blockDerivative derivatives[0]
    #define skyDerivative derivatives[1]

    vec3 T = normalize(dFdx(view));
    vec3 B = normalize(dFdy(view));
    vec3 N = cross(T, B);

    mat2x3 L = mat2x3(
      normalize(vec3(blockDerivative.x * T + 0.0005 * N + blockDerivative.y * B)),
      normalize(vec3(skyDerivative.x * T + 0.0005 * N + skyDerivative.y * B))
    );

    #define blockL L[0]
    #define skyL L[1]

    blockShading = flatten(_max0(dot(normal, blockL)), BLOCK_LIGHT_ANISOTROPY);
    skyShading = flatten(_max0(dot(normal, skyL)), SKY_LIGHT_ANISOTROPY);

    #undef blockL
    #undef skyL

    #undef blockDerivative
    #undef skyDerivative

    #undef blockShading
    #undef skyShading

    shading = saturate(_min(vec2(0.85), saturate(shading * 1.5)));

    return shading;
  }

#endif /* INTERNAL_INCLUDED_GBUFFER_DIRECTIONALLIGHTING */
