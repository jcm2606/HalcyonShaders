/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_OPAQUE_SHADOWS
  #define INTERNAL_INCLUDED_OPAQUE_SHADOWS

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

  #define hammersley(i, N) vec2( float(i) / float(N), float( bitfieldReverse(i) ) * 2.3283064365386963e-10 )
  #define circlemap(p) (vec2(cos((p).y*tau), sin((p).y*tau)) * p.x)

  // TODO: When a depth pre-pass is added to Optifine, fix solid shadows.

  void getShadows(io ShadowObject shadowObject, in vec3 viewFront, in vec3 viewBack, in float cloudShadow) {
    // GENERATE SHADOW POSITIONS
    mat3 shadowPosition = mat3(0.0);

    #define shadowPositionFront shadowPosition[0]
    #define shadowPositionBack shadowPosition[1]
    #define shadowPositionSolid shadowPosition[2]

    shadowPositionFront = worldToShadow(viewToWorld(viewFront));
    shadowPositionBack = worldToShadow(viewToWorld(viewBack));
    shadowPositionSolid = worldToShadow(viewToWorld(viewFront));

    // APPLY DEPTH BIAS
    c(float) shadowBias = 0.0004;
    shadowPositionFront.z += shadowBias;
    shadowPositionBack.z += shadowBias;
    shadowPositionSolid.z += shadowBias;

    // GENERATE ROTATION MATRIX
    vec2 pos = mod(gl_FragCoord.xy * 2.0, 64.0);
    float rotAngle = bayer64(pos) * tau;
    mat2 rotation = rotate2(rotAngle);

    // FIND BLOCKERS
    c(int) blockerSteps = 1;
    cRCP(float, blockerSteps);
    c(float) blockerSearchWidth = 0.001 * blockerStepsRCP;
    c(int) blockerSearchLOD = 0;
    c(float) blockerSearchWeight = 1.0 / pow(float(blockerSteps) * 2.0 + 1.0, 2.0);

    vec2 blocker = vec2(0.0);

    #define blockerFront blocker.x
    #define blockerBack blocker.y

    float blockerDepth = 0.0;
    float centerDepth = texture2DLod(shadowtex1, distortShadowPosition(shadowPositionSolid.xy, 1), blockerSearchLOD).x;

    vec2 blockerWeight = vec2(0.0);

    for(int i = -blockerSteps; i <= blockerSteps; i++) {
      for(int j = -blockerSteps; j <= blockerSteps; j++) {
        vec2 offset = vec2(i, j) * rotation * blockerSearchWidth;

        blockerDepth = texture2DLod(shadowtex1, distortShadowPosition(offset + shadowPositionFront.xy, 1), blockerSearchLOD).x;

        blockerFront += texture2DLod(shadowtex0, distortShadowPosition(offset + shadowPositionFront.xy, 1), blockerSearchLOD).x;
        blockerBack += blockerDepth;

        // EDGE PREDICTION
        blockerWeight.y += (blockerDepth - centerDepth < 0.007) ? (max0(blockerDepth - centerDepth) + max0(centerDepth - blockerDepth)) : 1.0;
      }
    }

    blocker *= blockerSearchWeight;
    blockerWeight *= blockerSearchWeight;

    // EDGE PREDICTION
    blockerWeight = clamp01(floor(blockerWeight * 256.0));
    blockerWeight.x = 1.0;

    shadowObject.edgePrediction = blockerWeight.y;

    // SAMPLE SHADOWS WITH PERCENTAGE-CLOSER FILTER
    c(float) lightDistance = lightSourceDistanceScaled;
    cRCP(float, lightDistance);
    c(int) shadowQuality = SHADOW_FILTER_QUALITY;
    cRCP(float, shadowQuality);
    c(float) weight = 1.0 / pow(float(shadowQuality) * 2.0 + 1.0, 2.0);
    
    c(float) minWidth = SHADOW_FILTER_MIN_WIDTH;
    c(float) maxWidth = SHADOW_FILTER_MAX_WIDTH;

    vec2 width = vec2(shadowPositionSolid.z, shadowPositionBack.z) - blocker;
    width *= lightDistanceRCP;
    //width *= blockerWeight;
    //width  = max(vec2(minWidth), width);
    #ifdef VC_SHADOW_SOFTENING
      width *= mix(VC_SHADOW_SOFTENING_STRENGTH, 1.0, pow(cloudShadow, vcShadowSofteningPowerScale));
    #endif
    width *= shadowPenumbraDistanceCompensation;
    width  = clamp(width, vec2(minWidth), vec2(maxWidth));
    width *= shadowQualityRCP;
    //vec2 width = clamp((vec2(shadowPositionSolid.z, shadowPositionBack.z) - blocker) * lightDistanceRCP, vec2(minWidth), vec2(maxWidth)) * shadowQualityRCP;

    mat2 widths = mat2(
      vec2(width.x) * rotation,
      vec2(width.y) * rotation
    );

    #define widthFront widths[0]
    #define widthBack widths[1]

    for(int i = -shadowQuality; i <= shadowQuality; i++) {
      for(int j = -shadowQuality; j <= shadowQuality; j++) {
        mat2 offsets = mat2(
          vec2(i, j) * widthFront,
          vec2(i, j) * widthBack
        );

      #define offsetFront offsets[0]
      #define offsetBack offsets[1]

      vec3 depths = vec3(
        texture2DLod(shadowtex1, distortShadowPosition(offsetBack + shadowPositionBack.xy, 1), 0).x,
        texture2DLod(shadowtex0, distortShadowPosition(offsetBack + shadowPositionBack.xy, 1), 0).x,
        texture2DLod(shadowtex1, distortShadowPosition(offsetFront + shadowPositionFront.xy, 1), 0).x
      );

      shadowObject.occlusionBack += CutShadow(compareShadow(depths.x, shadowPositionBack.z));
      shadowObject.occlusionFront += CutShadow(compareShadow(depths.y, shadowPositionBack.z));
      shadowObject.occlusionSolid += CutShadow(compareShadow(depths.z, shadowPositionFront.z));

      shadowObject.difference += ceil(depths.x - depths.y);

      float objectID = texture2DLod(shadowcolor1, distortShadowPosition(offsetFront + shadowPositionFront.xy, 1), 0).a * objectIDRange;
      float depthDifference = max0(shadowPositionBack.z - depths.y) * shadowDepthBlocks;

      vec3 shadowColour = toShadowHDR(texture2DLod(shadowcolor0, distortShadowPosition(offsetFront + shadowPositionFront.xy, 1), 0).rgb);
      shadowObject.colour += (depths.x > depths.y) ? (
        (comparef(objectID, OBJECT_WATER, ubyteMaxRCP)) ? interactWater(shadowColour, depthDifference) : shadowColour
      ) : vec3(1.0);

      /*
      shadowObject.colour += (depths.x > depths.y) ? texture2DLod(shadowcolor0, distortShadowPosition(offsetFront + shadowPositionFront.xy, 1), 0).rgb * ((comparef(objectID, OBJECT_WATER, ubyteMaxRCP)) ? absorbWater(depthDifference) : vec3(1.0)) : vec3(1.0);
      */

      #undef offsetFront
      #undef offsetBack
      }
    }

    shadowObject.occlusionBack *= weight;
    shadowObject.occlusionFront *= weight;
    shadowObject.occlusionSolid *= weight;

    shadowObject.difference *= weight;
    //shadowObject.difference  = ceil(shadowObject.difference);

    shadowObject.colour *= weight;

    #undef widthFront
    #undef widthBack

    #undef blockerFront
    #undef blockerBack

    #undef shadowPositionFront
    #undef shadowPositionBack
    #undef shadowPositionSolid
  }

  #undef hammersley
  #undef circlemap

#endif /* INTERNAL_INCLUDED_OPAQUE_SHADOWS */
