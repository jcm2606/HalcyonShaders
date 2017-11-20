/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_COMMON_DIFFUSEMODEl
  #define INTERNAL_INCLUDED_COMMON_DIFFUSEMODEl

  float lambert(in vec3 view, in vec3 light, in vec3 normal, in float roughness) {
    return max0(dot(normal, light));
  }

  float orenNayer(in vec3 view, in vec3 light, in vec3 normal, in float roughness) {
    roughness = pow2(roughness);

    float NdotL = dot(normal, light);
    float NdotV = dot(normal, view);

    float t = max(NdotL, NdotV);
    float g = max0(dot(view - normal * NdotV, light - normal * NdotL));

    return max0(NdotL) * ((0.45 * roughness / (roughness + 0.09)) * (g / t - g * t) + (0.285 / (roughness + 0.57) + 0.5));
  }

  float burley(in vec3 view, in vec3 light, in vec3 normal, in float roughness) {
    roughness = pow2(roughness);

    vec3 halfVector = normalize(view + light);

    float NdotL = max0(dot(normal, light));
    float LdotH = max0(dot(light, halfVector));
    float NdotV = max0(dot(normal, view));

    float energyFactor = -roughness * 0.337748344 + 1.0;
    float f90 = 2.0 * roughness * (LdotH * LdotH + 0.25) - 1.0;

    float lightScatter = f90 * pow5(1.0 - NdotL) + 1.0;
    float viewScatter = f90 * pow5(1.0 - NdotV) + 1.0;

    return NdotL * energyFactor * lightScatter * viewScatter;
  }

#endif /* INTERNAL_INCLUDED_COMMON_DIFFUSEMODEl */
