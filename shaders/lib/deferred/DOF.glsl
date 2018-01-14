/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_DEFERRED_DOF
  #define INTERNAL_INCLUDED_DEFERRED_DOF

  #include "/lib/common/util/BicubicSampler.glsl"

  vec3 drawDOF(io PositionObject position, in vec3 frame, in vec2 screenCoord, in float centerDepth) {
    #ifndef DOF
      return frame;
    #endif

    if(texture2D(depthtex2, screenCoord).x > position.depthBack) return frame;

    cv(int) samples = 8;
    cRCP(float, samples);

    cv(float) intensity = DOF_INTENSITY;

    cv(float) ditherScale = pow(128.0, 2.0);
    cv(float) fullSamples = samples * ditherScale;
    float dither = bayer128(gl_FragCoord.xy) * ditherScale;

    #ifndef DOF_FOCAL_POINT_AUTO
      centerDepth = getExpDepth(DOF_FOCAL_POINT);
    #endif

    #ifdef RENDER_DOF_WIDTH
      return vec3(abs(centerDepth - position.depthBack) * 10.0);
    #endif

    float depthDifference = abs(centerDepth - position.depthBack) * intensity;
    vec2 offsetScale = depthDifference * vec2(1.0, aspectRatio);

    vec3 blurredFrame = vec3(0.0);

    for(int i = 0; i < samples; i++) {
      vec2 offset = mapSpiral0(i * ditherScale + dither, fullSamples) * offsetScale;

      #ifdef DOF_DISPERSION
        blurredFrame.r += bicubic2D(colortex0, offset * dofDispersionR + screenCoord).r;
        blurredFrame.g += bicubic2D(colortex0, offset * dofDispersionG + screenCoord).g;
        blurredFrame.b += bicubic2D(colortex0, offset * dofDispersionB + screenCoord).b;
      #else
        blurredFrame += bicubic2D(colortex0, offset + screenCoord).rgb;
      #endif
    }

    return blurredFrame * samplesRCP;
  }

#endif /* INTERNAL_INCLUDED_DEFERRED_DOF */
