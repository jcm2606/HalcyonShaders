/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_COMMON_SHADOWS
  #define INTERNAL_INCLUDED_COMMON_SHADOWS

  #include "/lib/common/WaterAbsorption.glsl"

  struct ShadowObject {
    float occlusionBack;
    float occlusionFront;
    float occlusionSolid;

    float difference;
    vec3 colour;

    float edgePrediction;
  };

  #define NewShadowObject(name) ShadowObject name = ShadowObject(0.0, 0.0, 0.0, 0.0, vec3(0.0), 0.0)

  // NEW
  #define hammersley(i, N) vec2( float(i) / float(N), float( bitfieldReverse(i) ) * 2.3283064365386963e-10 )
  #define circlemap(p) (vec2(cos((p).y*tau), sin((p).y*tau)) * p.x)

  void getShadows(io ShadowObject shadowObject, in vec3 view, in float cloudShadow, in bool forward) {
    cv(int) shadowSamples = SHADOW_FILTER_QUALITY;
    cRCP(float, shadowSamples);

    cv(float) lightDistance = lightSourceDistanceScaled;
    cRCP(float, lightDistance);
    cv(float) minWidth = SHADOW_FILTER_MIN_WIDTH;
    cv(float) maxWidth = SHADOW_FILTER_MAX_WIDTH;

    cv(int) blockerSamples = 8;
    cRCP(float, blockerSamples);
    cv(float) blockerRadius = 1.0E-3;
    cv(int) blockerLOD = 0;

    cv(float) shadowBias = 0.5 * shadowMapResolutionRCP;

    vec3 shadowPosition = worldToShadow(viewToWorld(view));
    shadowPosition.z += shadowBias;

    cv(float) ditherScale = pow(128.0, 2.0);
    float dither = bayer128(gl_FragCoord.xy) * ditherScale;
    
    // BLOCKER SEARCH
    float centerDepth = texture2DLod(shadowtex1, distortShadowPosition(shadowPosition.xy, 1), blockerLOD).x;

    vec2 blockers = vec2(0.0);
    vec2 prediction = vec2(0.0);

    #define blockerFront blockers.x
    #define blockerBack blockers.y

    for(int i = 0; i < blockerSamples; i++) {
      vec2 coord = mapSpiral0(i * ditherScale + dither, blockerSamples * ditherScale) * blockerRadius + shadowPosition.xy;

      vec3 shadow = vec3(distortShadowPosition(coord, 1), shadowPosition.z);

      float backDepth = texture2DLod(shadowtex1, shadow.xy, blockerLOD).x;
      
      blockers += vec2(
        texture2DLod(shadowtex0, shadow.xy, blockerLOD).x,
        backDepth
      );

      // EDGE PREDICTION
      prediction.y += float(abs(backDepth - centerDepth) > 0.00175);
    }

    blockers *= blockerSamplesRCP;
    prediction *= blockerSamplesRCP;
    prediction  = ceil(prediction);

    prediction.x = 1.0;

    shadowObject.edgePrediction = prediction.y;

    // PENUMBRA RADIUS ESTIMATION
    cv(float) radiiScale = shadowDepthBlocks * lightDistanceRCP * shadowDistanceScale;

    vec2 radii  = vec2(shadowPosition.z) - blockers;
         radii *= radiiScale;
         //radii *= prediction;
         radii  = clamp(radii, vec2(minWidth), vec2(maxWidth));
         radii *= 1.0E-3;

    #define radiusFront radii.x
    #define radiusBack radii.y

    // FILTER
    for(int i = 0; i < shadowSamples; i++) {
      vec2 offset = mapSpiral0(i * ditherScale + dither, shadowSamples * ditherScale);

      vec3 shadowFront = vec3(distortShadowPosition(offset * radiusFront + shadowPosition.xy, 1), shadowPosition.z);
      vec3 shadowBack = vec3(distortShadowPosition(offset * radiusBack + shadowPosition.xy, 1), shadowPosition.z);

      vec2 depths = vec2(
        texture2DLod(shadowtex0, shadowFront.xy, 0).x,
        texture2DLod(shadowtex1, shadowBack.xy, 0).x
      );

      #define depthFront depths.x
      #define depthBack depths.y

      shadowObject.occlusionFront += CutShadow(compareShadow(depthFront, shadowFront.z));
      shadowObject.occlusionBack += CutShadow(compareShadow(depthBack, shadowBack.z));

      if(forward) continue;

      shadowObject.difference += sign(depthBack - depthFront);

      if(depthBack <= depthFront) continue;

      float objectID = texture2DLod(shadowcolor1, shadowFront.xy, 0).a * objectIDRange;
      float depthDifference = max0(shadowBack.z - depthFront) * shadowDepthBlocks;

      vec3 shadowColour = toShadowHDR(texture2DLod(shadowcolor0, shadowFront.xy, 0).rgb);
      shadowObject.colour += shadowColour * ((comparef(objectID, OBJECT_WATER, ubyteMaxRCP)) ? absorbWater(depthDifference) : vec3(1.0));
      //shadowObject.colour += (comparef(objectID, OBJECT_WATER, ubyteMaxRCP)) ? absorbWater(depthDifference) : shadowColour;

      #undef depthFront
      #undef depthBack
    }

    // NORMALIZE DATA
    shadowObject.occlusionFront *= shadowSamplesRCP;
    shadowObject.occlusionBack *= shadowSamplesRCP;

    shadowObject.difference *= shadowSamplesRCP;

    shadowObject.colour *= shadowSamplesRCP;

    #undef blockerFront
    #undef blockerBack
  }

  #undef hammersley
  #undef circlemap
  
#endif /* INTERNAL_INCLUDED_COMMON_SHADOWS */
