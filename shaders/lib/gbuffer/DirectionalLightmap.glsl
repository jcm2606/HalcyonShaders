/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_GBUFFER_DIRECTIONALLIGHTMAP
  #define INTERNAL_INCLUDED_GBUFFER_DIRECTIONALLIGHTMAP

  vec2 getLightmapShading(in vec2 lightmap, in vec3 surfaceNormal, in vec3 view, in float roughness, in mat3 tbn) {
    vec2 shading = lightmap;

    #define blockShading shading.x
    #define skyShading shading.y

    mat2 derivatives = mat2(
      vec2(dFdx(blockShading), dFdy(blockShading)) * 256.0,
      vec2(dFdx(skyShading), dFdy(skyShading)) * 256.0
    );

    #define blockDerivative derivatives[0]
    #define skyDerivative derivatives[1]

    vec3 T = normalize(dFdx(vView));
    vec3 B = normalize(dFdy(vView));
    vec3 N = cross(T, B);

    mat2x3 tangentL = mat2x3(
      normalize(vec3(blockDerivative.x * T + 0.0005 * N + blockDerivative.y * B)),
      normalize(vec3(skyDerivative.x * T + 0.0005 * N + skyDerivative.y * B))
    );

    #define lightBlock tangentL[0]
    #define lightSky tangentL[1]

    blockShading = max0(dot(surfaceNormal, lightBlock) * dlBlSteepnessA + dlBlSteepnessB);
    skyShading = max0(dot(surfaceNormal, lightSky) * dlSlSteepnessA + dlSlSteepnessB);

    #undef lightBlock
    #undef lightSky

    #undef blockDerivative
    #undef skyDerivative

    shading = clamp01(min(vec2(0.85), clamp01(shading * 1.5)));

    #undef blockShading
    #undef skyShading

    //shading.y = lightmap.y;

    return shading;//vec2(shading.x, lightmap.y);
  }
  
#endif /* INTERNAL_INCLUDED_GBUFFER_DIRECTIONALLIGHTMAP */
