/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#ifndef INTERNAL_INCLUDED_COMMON_RAYTRACER
  #define INTERNAL_INCLUDED_COMMON_RAYTRACER

  #include "/lib/util/SpaceConversion.glsl"

  #include "/lib/common/Sky.glsl"

  #include "/lib/common/Specular.glsl"

  cv(int) reflectionSamples = SPECULAR_SAMPLES;
  cRCP(float, reflectionSamples);

  vec3 reflectSky(in vec3 direction) {
    return drawSky(direction, SKY_MODE_REFLECT);
  }

  vec3 raytrace(const vec3 viewDirection, const vec3 viewPosition, vec3 p, in float skyOcclusion) {
    cv(float) quality = SPECULAR_QUALITY;
    int refines = SPECULAR_REFINEMENTS;
    cv(float) maxLength = 1.0 / quality;
    cv(float) minLength = 0.01 / quality;

    vec3 skyReflection = reflectSky(viewDirection) * skyOcclusion * _max0(dot(viewDirection, upDirection) * 0.5 + 0.5);

    vec3 direction = _normalize(viewToClip(viewPosition + viewDirection) - p);
    float rz = 1.0 / abs(direction.z);

    float stepLength = minLength;
    float depth = p.z;

    bool onScreen = true;

    while(depth >= p.z) {
      stepLength = clamp((depth - p.z) * rz, minLength, maxLength);
      p = direction * stepLength + p;
      if(saturate(p) != p) return skyReflection;
      depth = texture2D(depthtex2, p.xy).x;
    }

    while(refines-- > 0) {
      p = direction * clamp((depth - p.z) * rz, -stepLength, stepLength) + p;
      depth = texture2D(depthtex2, p.xy).x;
      stepLength *= 0.5;
    }

    bool visible = _distance(clipToView(p.xy, depth), clipToView(p.xy, p.z)) < 1.0;

    vec3 terrain = texture2DLod(colortex0, p.xy, 0).rgb;

    return (visible) ? terrain : skyReflection;
  }

  vec3 MakeSample(float p, float alpha2) {
    cv(float) phi = sqrt(5.0) * 0.5 + 0.5;
    cv(float) goldenAngle = tau / phi / phi;
    cv(float) _y = float(reflectionSamples) * 64.0 * 64.0 * goldenAngle;

    float x = (alpha2 * p) / (1.0 - p);
    float y = p * _y;

    float c = inversesqrt(x + 1.0);
    float s = sqrt(x) * c;

    return vec3(cos(y) * s, sin(y) * s, c);
  }

  vec3 raytraceRough(vec3 screenSpacePosition, vec3 viewSpacePosition, vec3 N, vec3 V, in float roughness, in vec3 f0, in float skyOcclusion, in vec2 dither) {
    float alpha = roughness * roughness;
    float alpha2 = alpha * alpha;

    float NoV = saturate(dot(N, V));

    vec3 tangent = _normalize(cross(gbufferModelView[1].xyz, N));
    mat3 tbn = mat3(tangent, cross(N, tangent), N);

    vec3 colour = vec3(0.0);

    vec3 H, L = vec3(0.0);
    float VoH = 0.0;

    for(int i = 0; i < reflectionSamples; ++i) {
      H = _normalize(tbn * MakeSample((dither.x + float(i)) * reflectionSamplesRCP, alpha2));
      L = -reflect(V, H);
      
      VoH = saturate(dot(V, H));

      #define NoL saturate(dot(N, L))

      colour = (raytrace(L, viewSpacePosition, screenSpacePosition, skyOcclusion) * Fresnel(f0, 1.0, VoH) * ExactCorrelatedG2(alpha, NoV, NoL)) * reflectionSamplesRCP + colour;;

      #undef NoL
    }

    return colour;
  }

#endif /* INTERNAL_INCLUDED_COMMON_RAYTRACER */
