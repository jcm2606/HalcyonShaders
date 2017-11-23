/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_GBUFFER_PARALLAXTRANSPARENT
  #define INTERNAL_INCLUDED_GBUFFER_PARALLAXTRANSPARENT

  vec3 getParallax(in vec3 world, in vec3 view, in float objectID) {
    c(float) steps = 4;
    cRCP(float, steps);

    c(float) height = PARALLAX_TRANSPARENT_DEPTH_WATER;

    float waveHeight = getHeight(world, objectID) * height;

    for(int i = 0; i < steps; i++) {
      world.xz = waveHeight * view.xy + world.xz;

      waveHeight = getHeight(world, objectID) * height;
    }

    return world;
  }

#endif /* INTERNAL_INCLUDED_GBUFFER_PARALLAXTRANSPARENT */
