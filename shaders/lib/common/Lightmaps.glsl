/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#ifndef INTERNAL_INCLUDED_COMMON_LIGHTMAPS
  #define INTERNAL_INCLUDED_COMMON_LIGHTMAPS

  float getBlockLightmap(in float blockLight) {
    return _pow(blockLight, BLOCK_LIGHT_ATTENUATION) * BLOCK_LIGHT_INTENSITY;
  }

  float getSkyLightmap(in float skyLight) {
    return _pow(skyLight, SKY_LIGHT_ATTENUATION) * SKY_LIGHT_INTENSITY;
  }

#endif /* INTERNAL_INCLUDED_COMMON_LIGHTMAPS */
