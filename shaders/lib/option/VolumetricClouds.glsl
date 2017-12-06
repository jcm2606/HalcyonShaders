/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_OPTION_VOLUMETRICCLOUDS
  #define INTERNAL_INCLUDED_OPTION_VOLUMETRICCLOUDS

  #define VOLUMETRIC_CLOUDS // When enabled, the shader will render all volumetric cloud effects, including the clouds themselves and cloud shadows. Volumetric clouds are an alternative method of rendering dynamic clouds, where the shader renders them as a 3D volume, instead of a 2D plane. This not only allows the player to fly through the clouds, but also allows lighting to be far more accurate.

  //#define VC_SHADOW_SOFTENING // When enabled, cloud shadows soften shadows projected by other geometry.
  #define VC_SHADOW_SOFTENING_STRENGTH 256.0 // How strong should shadow softening be? [4.0 8.0 16.0 32.0 64.0 128.0 256.0 512.0 1024.0]

  c(float) vcShadowSofteningPowerScale = 1.0 / VC_SHADOW_SOFTENING_STRENGTH;

  #define VC_QUALITY 6 // How many samples should be taken for volumetric clouds?. Higher number means better quality clouds, especially in the distance, at a significant cost to performance. [4 6 8 10 12 14 16]
  #define VC_OCTAVES 5 // How many octaves of noise should be used for the cloud FBM?. Higher number means the shape of clouds is more detailed, at the cost of performance. [3 4 5 6 7 8 9]
  
  #define VC_DENSITY_CLEAR 2200.0 // How dense are clouds during clear weather? [1800.0 2000.0 2200.0 2400.0 2600.0 2800.0 3000.0 3200.0 3400.0 3600.0 3800.0 4000.0 4200.0 4400.0 4600.0 4800.0 5000.0 5200.0 5400.0 5600.0 5800.0 6000.0 6200.0]
  #define VC_DENSITY_OVERCAST 2800.0 // How much density is added during overcast weather? [1800.0 2000.0 2200.0 2400.0 2600.0 2800.0 3000.0 3200.0 3400.0 3600.0 3800.0 4000.0 4200.0 4400.0 4600.0 4800.0 5000.0 5200.0 5400.0 5600.0 5800.0 6000.0 6200.0]
  #define VC_DENSITY_RAIN 5400.0 // How dense are clouds during rainy weather? [1800.0 2000.0 2200.0 2400.0 2600.0 2800.0 3000.0 3200.0 3400.0 3600.0 3800.0 4000.0 4200.0 4400.0 4600.0 4800.0 5000.0 5200.0 5400.0 5600.0 5800.0 6000.0 6200.0]

  c(float) cloudOvercastOffsetDensity = abs(VC_DENSITY_OVERCAST - VC_DENSITY_CLEAR);

  #define VC_COVERAGE_CLEAR 1.5 // How large are clouds during clear weather?. Smaller number = larger clouds. [1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7]
  #define VC_COVERAGE_OVERCAST 0.9 // How large are clouds during overcast weather?. Smaller number = larger clouds. [0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2]
  #define VC_COVERAGE_RAIN 0.3 // How large are clouds during rainy weather?. Smaller number = larger clouds. [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]

  c(float) cloudOvercastOffsetCoverage = abs(VC_COVERAGE_CLEAR - VC_COVERAGE_OVERCAST);

  #define VC_LIGHTING_QUALITY_DIRECT 4 // How many steps should be taken for direct lighting?. Higher number means more accurate lighting, at the cost of performance. [1 2 4 6 8 10 12 14 16]
  #define VC_LIGHTING_QUALITY_SKY 2 // How many steps should be taken for sky lighting?. Higher number means more accurate lighting, at the cost of performance. [1 2 4 6 8 10 12 14 16]
  #define VC_LIGHTING_QUALITY_BOUNCED 2 // How many steps should be taken for bounced lighting?. Higher number means more accurate lighting, at the cost of performance. [1 2 4 6 8 10 12 14 16]

  #define VC_ALTITUDE 4096.0 // How high in the world should clouds start? [1024.0 2048.0 4096.0 8192.0 16384.0]
  #define VC_HEIGHT 1024.0 // How high should clouds themselves be? [256.0 512.0 768.0 1024.0 1280.0 1536.0 1792.0 2048.0]

#endif /* INTERNAL_INCLUDED_OPTION_VOLUMETRICCLOUDS */
