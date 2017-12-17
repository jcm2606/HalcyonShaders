/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_COMMON_ATMOSPHERE
  #define INTERNAL_INCLUDED_COMMON_ATMOSPHERE

  cv(float) atmosphereHeight = 8000.0;
  cv(float) earthRadius = 6371000.0;
  cv(float) mieMultiplier = 1.3;
  cv(float) ozoneMultiplier = 1.0;
  cv(float) rayleighDistribution = 8.0;
  cRCP(float, rayleighDistribution);
  cv(float) mieDistribution = 1.8;
  cv(vec3) rayleighCoeff = vec3(5.8E-6, 1.35E-5, 3.31E-5);
  cv(vec3) ozoneCoeff = vec3(3.426, 8.298, 0.356) * 6.0E-5 / 100.0;
  cv(float) mieCoeff = 3.0E-6 * mieMultiplier;

  vec2 getThickness(in vec3 dir) {
    vec2 sr = earthRadius + vec2(atmosphereHeight, atmosphereHeight * mieDistribution * rayleighDistributionRCP);

    vec3 ro = -upVector * earthRadius;

    float b = dot(dir, ro);

    return b + sqrt(sr * sr + (b * b - flengthsqr(ro)));
  }

  #define getEarth(a) smoothstep(-0.1, 0.1, dot(upVector, a))
  #define phaseRayleigh(a) (0.4 * a + 1.14)

  float phaseMie(in float x) {
    cv(vec3) c = vec3(0.25609, 0.132268, 0.010016);
    cv(vec3) d = vec3(-1.5, -1.74, -1.98);
    cv(vec3) e = vec3(1.5625, 1.7569, 1.9801);

    return dot((x * x + 1.0) * c / pow(d * x + e, vec3(1.5)), vec3(0.333333));
  }

  vec3 absorb(in vec2 a) {
    return exp(-a.x * (ozoneCoeff * ozoneMultiplier + rayleighCoeff) - 1.11 * a.y * mieCoeff);
  }

  cv(int) atmosphereSteps = 8;
  cRCP(float, atmosphereSteps);

  vec3 getAtmosphere(in vec3 background, in vec3 view, in int mode) {
    vec2 thickness = getThickness(view) * atmosphereStepsRCP;

    float VdotS = dot(view, sunVector);
    float VdotM = dot(view, moonVector);

    vec3 viewAbsorb = absorb(thickness);
    vec4 scatterCoeff = 1.0 - exp(-thickness.xxxy * vec4(rayleighCoeff, mieCoeff));

    vec3 scatterS = scatterCoeff.xyz * phaseRayleigh(VdotS) + (scatterCoeff.w * phaseMie((mode == 2) ? 0.0 : VdotS));
    vec3 scatterM = scatterCoeff.xyz * phaseRayleigh(VdotM) + (scatterCoeff.w * phaseMie((mode == 2) ? 0.0 : VdotM));

    cv(float) sunBrightness = 1.5;
    cv(float) moonBrightness = 0.002;
    cv(float) moonLightBrightness = pow(16.0, 6.0);
    cv(vec3) moonColour = _saturation(vec3(0.0, 0.0, 1.0), 0.7);

    vec3 absorbS = absorb(getThickness(sunVector) * atmosphereStepsRCP) * getEarth(sunVector) * sunBrightness;
    vec3 absorbM = absorb(getThickness(moonVector) * atmosphereStepsRCP) * getEarth(moonVector) * moonBrightness;

    vec3 skyS = mode != 0 ? vec3(0.0) : (sin(max0(pow(VdotS, 24.0 * sunSpotSizeRCP) - 0.9935) / 0.015 * pi) * absorbS * sunBrightness) * (SUN_BRIGHTNESS * 2.0) + background;
    vec3 skyM = mode != 0 ? vec3(0.0) : (sin(max0(pow16(VdotM) - 0.9935) / 0.015 * pi) * absorbM * moonBrightness * moonColour) * moonLightBrightness + background;

    for(int i = 0; i < atmosphereSteps; i++) {
      scatterS *= absorbS;
      scatterM *= absorbM;

      skyS = skyS * viewAbsorb + scatterS;
      skyM = skyM * viewAbsorb + scatterM;
    }

    return skyS + skyM;
  }

#endif /* INTERNAL_INCLUDED_COMMON_ATMOSPHERE */
