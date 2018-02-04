/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#ifndef INTERNAL_INCLUDED_GBUFFER_PARALLAXWATER
  #define INTERNAL_INCLUDED_GBUFFER_PARALLAXWATER

  #if PROGRAM == GBUFFERS_WATER
    #include "/lib/common/Normals.glsl"

    vec3 getParallax(in vec3 world, in vec3 view, in float objectID) {
      cv(int) steps = 6;
      cRCP(float, steps);

      cv(float) height = 1.4;

      view.xy = view.xy * stepsRCP / _length(view) * 4.0;

      float waveHeight = getHeight(world, objectID) * height;

      for(int i = 0; i < steps; ++i) {
        world.xz = waveHeight * view.xy - world.xz;

        waveHeight = getHeight(world, objectID) * height;
      }

      return world;
    }
  #endif

#endif /* INTERNAL_INCLUDED_GBUFFER_PARALLAXWATER */
