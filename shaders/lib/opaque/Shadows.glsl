/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_OPAQUE_SHADOWS
  #define INTERNAL_INCLUDED_OPAQUE_SHADOWS

  struct ShadowObject {
    float occlusionBack;
    float occlusionFront;
    float occlusionSolid;

    float difference;
    vec3 colour;
  };

  #define NewShadowObject(name) ShadowObject name = ShadowObject(0.0, 0.0, 0.0, 0.0, vec3(0.0))

  #define hammersley(i, N) vec2( float(i) / float(N), float( bitfieldReverse(i) ) * 2.3283064365386963e-10 )
  #define circlemap(p) (vec2(cos((p).y*tau), sin((p).y*tau)) * p.x)

  void getShadows(io GbufferObject gbuffer, io MaskObject mask, io PositionObject position, io ShadowObject shadowObject, in vec2 screenCoord) {
    // GENERATE SHADOW POSITIONS
    mat3 shadowPosition = mat3(0.0);

    #define shadowPositionFront shadowPosition[0]
    #define shadowPositionBack shadowPosition[1]
    #define shadowPositionSolid shadowPosition[2]

    shadowPositionFront = worldToShadow(viewToWorld(position.viewPositionFront));
    shadowPositionBack = worldToShadow(viewToWorld(position.viewPositionBack));
    shadowPositionSolid = worldToShadow(viewToWorld(position.viewPositionBack));

    // APPLY DEPTH BIAS
    c(float) shadowBias = -0.0003;
    shadowPositionFront.z += shadowBias;
    shadowPositionBack.z += shadowBias;
    shadowPositionSolid.z += shadowBias;

    // GENERATE ROTATION MATRIX
    vec2 pos = mod(gl_FragCoord.xy * 2.0, 64.0);
    float rotAngle = bayer64(pos) * tau;
    mat2 rotation = rotate2(rotAngle);

    // FIND BLOCKERS
    c(float) blockerSearchWidth = 0.001;
    c(int) blockerSearchLOD = 1;

    vec2 blocker = vec2(0.0);

    #define blockerFront blocker.x
    #define blockerBack blocker.y

    float blockerDepth = 0.0;
    float centerDepth = texture2DLod(shadowtex1, distortShadowPosition(shadowPositionSolid.xy, 1), blockerSearchLOD).x;

    vec2 blockerWeight = vec2(0.0);

    for(int i = -1; i <= 1; i++) {
      for(int j = -1; j <= 1; j++) {
        vec2 offset = (vec2(i, j) + 0.5) * rotation * blockerSearchWidth;

        blockerDepth = texture2DLod(shadowtex0, distortShadowPosition(offset + shadowPositionSolid.xy, 1), blockerSearchLOD).x;

        blockerFront += blockerDepth;
        blockerBack += texture2DLod(shadowtex1, distortShadowPosition(offset + shadowPositionBack.xy, 1), blockerSearchLOD).x;

        blockerWeight.y += (max0(blockerDepth - centerDepth) + max0(centerDepth - blockerDepth));
      }
    }

    c(float) iterRCP = 1.0 / 9.0;
    blocker *= iterRCP;
    blockerWeight *= iterRCP;

    blockerWeight = clamp01(floor(blockerWeight * 256.0));
    blockerWeight.x = 1.0;

    shadowObject.difference = blockerWeight.y; return;

    // SAMPLE SHADOWS WITH PERCENTAGE-CLOSER FILTER
    c(float) lightDistance = 32.0;
    cRCP(float, lightDistance);
    c(int) shadowQuality = SHADOW_FILTER_QUALITY;
    cRCP(float, shadowQuality);
    c(float) weight = 1.0 / pow(float(shadowQuality) * 2.0 + 1.0, 2.0);
    
    c(float) minWidth = 0.00005;
    c(float) maxWidth = 0.00075;

    vec2 width = clamp((vec2(shadowPositionSolid.z, shadowPositionBack.z) - blocker) * lightDistanceRCP * blockerWeight, vec2(minWidth), vec2(maxWidth)) * shadowQualityRCP;

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

      vec2 depths = vec2(
        texture2DLod(shadowtex1, distortShadowPosition(offsetBack + shadowPositionBack.xy, 1), 0).x,
        texture2DLod(shadowtex0, distortShadowPosition(offsetFront + shadowPositionBack.xy, 1), 0).x
      );

      // ADD-IN POINT: Stored depths.

      shadowObject.occlusionBack += ceil(compareShadow(depths.x, shadowPositionBack.z));
      shadowObject.occlusionFront += ceil(compareShadow(depths.y, shadowPositionBack.z));

      #undef offsetFront
      #undef offsetBack
      }
    }

    shadowObject.occlusionBack *= weight;
    shadowObject.occlusionFront *= weight;

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
