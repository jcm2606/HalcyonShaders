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

    cv(float) intensity = 0.05;

    cv(float) ditherScale = pow(16.0, 2.0);
    float dither = bayer128(gl_FragCoord.xy) * ditherScale;

    float depthDifference = abs(centerDepth - position.depthBack) * intensity;

    vec3 blurredFrame = vec3(0.0);

    for(int i = 0; i < samples; i++) {
      vec2 offset = mapSpiral0(i * ditherScale + dither, samples * ditherScale) * depthDifference;

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
