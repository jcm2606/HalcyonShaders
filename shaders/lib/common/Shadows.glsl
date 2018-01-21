/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#ifndef INTERNAL_INCLUDED_COMMON_SHADOW
  #define INTERNAL_INCLUDED_COMMON_SHADOW

  #include "/lib/util/SpaceConversion.glsl"
  #include "/lib/util/ShadowConversion.glsl"

  struct ShadowData {
    float occlusionFront;
    float occlusionBack;
    float occlusionDifference;

    float depthFront;
    float depthBack;
    float depthDifference;
    float depthWater;

    float bouncedWeight;

    vec3 colour;

    float isWater;
  };

  #define _newShadowData(name) ShadowData name = ShadowData( 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, vec3(0.0), 0.0 )

  void computeShadowing(io ShadowData shadowData, in vec3 view, in vec2 dither, in float cloudShadow, in bool forward) {
    // OPTIONS
    cv(int) filterSamples = SHADOW_QUALITY;
    cRCP(float, filterSamples);

    cv(int) blockerSamples = 5;
    cRCP(float, blockerSamples);
    cv(float) blockerRadius = 1.0 * 1.0E-3;
    cv(int) blockerLOD = 0;

    cv(float) lightRadius = tan(radians(SUN_SIZE));
    cv(float) minWidth = 2.0 * shadowMapResolutionRCP;
    cv(float) maxWidth = 4.0;
    
    // PERFORM EARLY FORWARD PREPARATIONS
    if(forward) shadowData.colour = vec3(1.0);

    // COMPUTE WORLD POSITION
    vec3 world = viewToWorld(view);

    // COMPUTE SHADOW POSITION
    vec3 shadowPosition = worldToShadow(world);

    // APPLY BIAS
    cv(float) shadowBias = 0.75 * shadowMapResolutionRCP;
    shadowPosition.z += shadowBias;

    // PREALLOCATE VARIABLES
    vec2 shadow = vec2(0.0);

    // BLOCKER SEARCH
    vec2 blockers = vec2(0.0);

    for(int i = 0; i < blockerSamples; i++) {
      shadow = distortShadowPosition(spiralMap(i * dither.y + dither.x, blockerSamples * dither.y) * blockerRadius + shadowPosition.xy, true);

      blockers = vec2(
        texture2DLod(shadowtex1, shadow.xy, blockerLOD).x,
        texture2DLod(shadowtex0, shadow.xy, blockerLOD).x
      ) * blockerSamplesRCP + blockers;
    }

    // PENUMBRA RADIUS ESTIMATION
    cv(float) radiiScale = lightRadius * shadowDepthBlocks * shadowDistanceScale;

    vec2 radii  = vec2(shadowPosition.z) - blockers;
         radii *= radiiScale;
         radii  = clamp(radii, vec2(minWidth), vec2(maxWidth));
         radii *= 5.0E-3;

    #define radiusBack radii.x
    #define radiusFront radii.y

    // PREALLOCATE VARIABLES
    vec3 shadowBack, shadowFront, shadowColour = vec3(0.0);
    vec2 offset, depths = vec2(0.0);
    float waterDepth = 0.0;
    bool isWater = false;

    // FILTER
    for(int i = 0; i < filterSamples; i++) {
      offset = spiralMap(i * dither.y + dither.x, filterSamples * dither.y);

      shadowBack = vec3(distortShadowPosition(offset * radiusBack + shadowPosition.xy, true), shadowPosition.z);
      shadowFront = vec3(distortShadowPosition(offset * radiusFront + shadowPosition.xy, true), shadowPosition.z);

      depths = vec2(
        texture2DLod(shadowtex1, shadowBack.xy, 0).x,
        texture2DLod(shadowtex0, shadowFront.xy, 0).x
      );

      shadowData.depthBack = depths.x * filterSamplesRCP + shadowData.depthBack;
      shadowData.depthFront = depths.y * filterSamplesRCP + shadowData.depthFront;

      shadowData.occlusionBack = _cutShadow(compareShadowDepth(depths.x, shadowBack.z)) * filterSamplesRCP + shadowData.occlusionBack;
      shadowData.occlusionFront = _cutShadow(compareShadowDepth(depths.y, shadowFront.z)) * filterSamplesRCP + shadowData.occlusionFront;
      
      if(forward) continue;

      shadowData.occlusionDifference = float(depths.x - depths.y > 0.0);

      if(depths.x - depths.y <= 0.0) continue;

      isWater = texture2D(shadowcolor1, shadowFront.xy).a > 0.5;
      shadowData.isWater += float(isWater) * filterSamplesRCP + shadowData.isWater;

      shadowColour = toHDR(texture2DLod(shadowcolor0, shadowFront.xy, 0).rgb, dynamicRangeShadow);

      if(isWater) {
        waterDepth = depths.y * 8.0 - 4.0;
        waterDepth = waterDepth * shadowProjectionInverse[2].z + shadowProjectionInverse[3].z;
        waterDepth = (_transMAD(shadowModelView, world)).z - waterDepth;

        shadowData.depthWater = waterDepth * filterSamplesRCP + shadowData.depthWater;

        if(waterDepth < 0.0) shadowColour *= exp(waterTransmittanceCoeff * waterDepth * VOLUMETRIC_WATER_DENSITY);
      }

      shadowData.colour = shadowColour * filterSamplesRCP + shadowData.colour;
    }

    #undef radiusBack
    #undef radiusFront
  }

#endif /* INTERNAL_INCLUDED_COMMON_SHADOW */
