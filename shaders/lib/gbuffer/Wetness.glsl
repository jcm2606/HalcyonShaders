/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_GBUFFER_WETNESS
  #define INTERNAL_INCLUDED_GBUFFER_WETNESS

  #include "/lib/common/util/Noise.glsl"

  float puddleFBM(in vec3 world) {
    float puddle = 1.0;

    vec2 position = world.xz - world.y;
    cv(mat2) rot = rot2(0.7);

    position *= rot;
    position *= 0.001;

    float weight = 0.5;
    float totalWeight = 0.0;

    for(int i = 0; i < 3; i++) {
      totalWeight += weight;

      puddle -= texnoise2D(noisetex, position) * weight;

      position *= 2.0;
      position *= rot;
      weight *= 0.5;
    }
    
    puddle  = puddle / totalWeight;
    //puddle -= 0.01;
    puddle  = max0(puddle);
    //puddle  = sqrt(puddle);

    return clamp01(puddle);
  }

  float getWetness(in vec3 world) {
    float wetnessMask = 0.0;

    wetnessMask = max(0.65, puddleFBM(world));

    return clamp01(wetnessMask) * wetness;
  }

#endif /* INTERNAL_INCLUDED_GBUFFER_WAVINGTERRAIN */
