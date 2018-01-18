/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#ifndef INTERNAL_INCLUDED_COMMON_SPECULAR
  #define INTERNAL_INCLUDED_COMMON_SPECULAR

  vec3 Fresnel(vec3 f0, float f90, float LoH) {
    return (f90 - f0) * exp2((-5.55473 * LoH - 6.98316) * LoH) + f0;;
  }

  float ExactCorrelatedG2(float a, float NoV, float NoL) {
    #if 1
      a *= a;
      float x = 2.0 * NoL * NoV;
      float y = (1.0 - a);
      return saturate((2.0 * NoL * NoV) / (NoV * sqrt(a + y * _pow(NoL, 2.0)) + NoL * sqrt(a + y * _pow(NoV, 2.0))));
    #else
      float x = 2.0 * NoL * NoV + 1e-36;
      return saturate(x / mix(x, NoL + NoV + 1e-36, a));
    #endif
  }

  float D_GGX(float a2, float NoH) {
    float d = (NoH * a2 - NoH) * NoH + 1.0;
    return a2 / (d * d);
  }

  vec3 BRDF(vec3 V, vec3 L, vec3 N, float r, vec3 f0) {
    float a  = r * r;
    float a2 = a * a;

    vec3 H = normalize(L + V);

    float NoL = saturate(dot(N, L));
    float NoV = abs(dot(N, V) + 1.0E-6);
    float NoH = saturate(dot(N, H));
    float LoH = saturate(dot(L, H));

    return _max(vec3(0.0), (Fresnel(f0, 1.0, LoH) * D_GGX(a2, NoH)) * ExactCorrelatedG2(a, NoV, NoL) / (pi * 4.0 * NoL * NoV)) * NoL;
  }

  float GGX(vec3 V, vec3 N, vec3 L, float r, float f0) {
    float a2 = _pow(r, 4.0);

    vec3 H = normalize(L + V);

    float HoL = saturate(dot(H, L));

    #define NoL saturate(dot(N, L))
    #define NoH saturate(dot(N, H))

    #define F ( (1.0 - f0) * _pow(1.0 - HoL, 5.0) + f0 )

    #define denom ( _pow(NoH, 2.0) * (a2 - 1.0) + 1.0 )

    return NoL * a2 / (pi * _pow(denom, 2.0)) * F / (_pow(HoL, 2.0) * (1.0 - a2) + a2);

    #undef NoL
    #undef NoH

    #undef F

    #undef denom
  }

#endif /* INTERNAL_INCLUDED_COMMON_SPECULAR */
