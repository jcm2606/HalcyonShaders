/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
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

    vec3 ro = -upDirection * earthRadius;

    float b = dot(dir, ro);

    return b + sqrt(sr * sr + (b * b - _lengthsqr(ro)));
  }

  #define _getEarth(x) ( smoothstep(-0.1, 0.1, dot(upDirection, x)) )
  #define phaseRayleigh(x) ( 0.4 * x + 1.14 )

  float phaseMie(in float x) {
    cv(vec3) c = vec3(0.25609, 0.132268, 0.010016);
    cv(vec3) d = vec3(-1.5, -1.74, -1.98);
    cv(vec3) e = vec3(1.5625, 1.7569, 1.9801);

    return dot((x * x + 1.0) * c / _pow(d * x + e, vec3(1.5)), vec3(0.333333));
  }

  vec3 absorb(in vec2 a) {
    return exp(-a.x * (ozoneCoeff * ozoneMultiplier + rayleighCoeff) - 1.11 * a.y * mieCoeff);
  }

  vec3 getLightColour(in vec3 direction) {
    return absorb(getThickness(direction)) * _getEarth(direction) * ((sunAngle <= 0.5) ? SUN_LIGHT_INTENSITY : MOON_LIGHT_INTENSITY);
  }

  float getBodyMask(in float VoL, cin(float) sizeDegrees) {
    return step(pi - radians(sizeDegrees), acos(-VoL));
  }

  vec3 getAtmosphere(in vec3 background, in vec3 view, in int mode) {
    cv(int) steps = 8;
    cRCP(float, steps);

    vec2 thickness = getThickness(view) * stepsRCP;

    float VoS = dot(view, sunDirection);
    float VoM = dot(view, moonDirection);

    vec3 viewAbsorb = absorb(thickness);
    vec4 scatterCoeff = 1.0 - exp(-thickness.xxxy * vec4(rayleighCoeff, mieCoeff));

    vec3 scatterS = scatterCoeff.xyz * phaseRayleigh(VoS) + (scatterCoeff.w * phaseMie((mode > 0) ? 0.0 : VoS));
    vec3 scatterM = scatterCoeff.xyz * phaseRayleigh(VoM) + (scatterCoeff.w * phaseMie((mode > 0) ? 0.0 : VoM));

    cv(float) sunScatterIntensity = 1.5;
    cv(float) moonScatterIntensity = 0.002;

    vec3 absorbS = absorb(getThickness(sunDirection) * stepsRCP) * _getEarth(sunDirection) * sunScatterIntensity;
    vec3 absorbM = absorb(getThickness(moonDirection) * stepsRCP) * _getEarth(moonDirection) * moonScatterIntensity;

    cv(float) sunSpotIntensity = SUN_LIGHT_INTENSITY * SUN_SPOT_MULTIPLIER;
    cv(float) moonSpotIntensity = MOON_LIGHT_INTENSITY * MOON_SPOT_MULTIPLIER;

    vec3 skyS = (vec3(float(mode == 0)) * getBodyMask(VoS, SUN_SIZE)) * sunSpotIntensity + background;
    vec3 skyM = (vec3(float(mode == 0)) * getBodyMask(VoM, MOON_SIZE)) * moonSpotIntensity + background;

    for(int i = 0; i < steps; ++i) {
      scatterS *= absorbS;
      scatterM *= absorbM;

      skyS = skyS * viewAbsorb + scatterS;
      skyM = skyM * viewAbsorb + scatterM;
    }

    return skyS + skyM;
  }

#endif /* INTERNAL_INCLUDED_COMMON_ATMOSPHERE */
