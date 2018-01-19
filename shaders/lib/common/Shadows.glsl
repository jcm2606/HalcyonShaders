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

    float bouncedWeight;

    vec3 colour;
  };

  #define _newShadowData(name) ShadowData name = ShadowData( 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, vec3(0.0) )

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

    // COMPUTE SHADOW POSITION
    vec3 shadowPosition = worldToShadow(viewToWorld(view));

    // APPLY BIAS
    cv(float) shadowBias = 0.75 * shadowMapResolutionRCP;
    shadowPosition.z += shadowBias;

    // BLOCKER SEARCH
    vec2 blockers = vec2(0.0);

    for(int i = 0; i < blockerSamples; i++) {
      vec2 shadow = distortShadowPosition(spiralMap(i * dither.y + dither.x, blockerSamples * dither.y) * blockerRadius + shadowPosition.xy, true);

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

    // FILTER
    for(int i = 0; i < filterSamples; i++) {
      vec2 offset = spiralMap(i * dither.y + dither.x, filterSamples * dither.y);

      vec3 shadowBack = vec3(distortShadowPosition(offset * radiusBack + shadowPosition.xy, true), shadowPosition.z);
      vec3 shadowFront = vec3(distortShadowPosition(offset * radiusFront + shadowPosition.xy, true), shadowPosition.z);

      vec2 depths = vec2(
        texture2DLod(shadowtex1, shadowBack.xy, 0).x,
        texture2DLod(shadowtex0, shadowFront.xy, 0).x
      );

      shadowData.depthBack = depths.x * filterSamplesRCP + shadowData.depthBack;
      shadowData.depthFront = depths.y * filterSamplesRCP + shadowData.depthFront;

      shadowData.occlusionBack = _cutShadow(compareShadowDepth(depths.x, shadowBack.z)) * filterSamplesRCP + shadowData.occlusionBack;
      shadowData.occlusionFront = _cutShadow(compareShadowDepth(depths.y, shadowFront.z)) * filterSamplesRCP + shadowData.occlusionFront;
      
      if(forward) continue;

      shadowData.occlusionDifference = sign(_max0(depths.x - depths.y)) * filterSamplesRCP + shadowData.occlusionDifference;

      if(depths.x - depths.y <= 0.0) continue;

      float objectID = texture2DLod(shadowcolor1, shadowFront.xy, 0).a * objectIDMax;

      vec3 shadowColour = toHDR(texture2DLod(shadowcolor0, shadowFront.xy, 0).rgb, dynamicRangeShadow);
      shadowData.colour = shadowColour * filterSamplesRCP + shadowData.colour; // TODO: Water absorption on shadow colour.
    }

    #undef radiusBack
    #undef radiusFront
  }

#endif /* INTERNAL_INCLUDED_COMMON_SHADOW */
