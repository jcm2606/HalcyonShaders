/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_COMMON_LIGHTMAPS
  #define INTERNAL_INCLUDED_COMMON_LIGHTMAPS

  float getBlockLightmap(in float blockLight) {
    return pow(blockLight, 4.0);
  }

  float getSkyLightmap(in float skyLight, in vec3 normal) {
    return pow(skyLight, 5.0) * max0(dot(normal, upVector) * 0.45 + 0.65);
  }

#endif /* INTERNAL_INCLUDED_COMMON_LIGHTMAPS */
