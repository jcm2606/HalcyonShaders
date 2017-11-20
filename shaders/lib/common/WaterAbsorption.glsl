/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_COMMON_WATERABSORPTION
  #define INTERNAL_INCLUDED_COMMON_WATERABSORPTION

  vec3 absorbWater(in float dist) { return pow(waterColour, vec3(dist) * WATER_ABSORPTION_COEFF); }

  vec3 interactWater(in vec3 colour, in float dist) {
    return mix(
      impurityColour,
      colour,
      exp2(-dist * 0.35)
    ) * absorbWater(dist);
  }
  
#endif /* INTERNAL_INCLUDED_COMMON_WATERABSORPTION */
