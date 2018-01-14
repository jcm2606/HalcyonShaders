/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_COMMON_RAYTRACER
  #define INTERNAL_INCLUDED_COMMON_RAYTRACER

  #ifndef INTERNAL_INCLUDED_UTIL_SPACETRANSFORM
    #include "/lib/common/util/SpaceTransform.glsl"
  #endif

  #define faceVisible() abs(pos.z - currDepth) < abs(stepLength * direction.z)
  #define onScreen() (floor(pos.xy) == vec2(0.0))

  vec4 raytraceClip(in sampler2D tex, in vec3 dir, in vec3 view) {
    cv(int) quality = 8;
    cRCP(float, quality);
    cv(int) steps = quality + 4;

    vec3 clip = viewToClip(view);

    vec3 direction = normalize(viewToClip(view + dir) - clip);
    direction.xy = normalize(direction.xy);

    vec3 maxLengths = (step(0.0, direction) - clip) / direction;

    float maxStepLength = min(min(maxLengths.x, maxLengths.y), maxLengths.z) * qualityRCP;
    float minStepLength = maxStepLength * 0.1;

    float stepLength = maxStepLength * (0.0 * 0.9 + 0.1);
    float stepWeight = 1.0 / abs(direction.z);
    vec3 pos = direction * stepLength + clip;
    ;
    float currDepth = texture2D(depthtex1, pos.xy).x;

    bool rayHit = false;

    for(int i = 0; i < steps; i++) {
      rayHit = currDepth < pos.z;

      if(rayHit || !onScreen()) break;

      stepLength = (currDepth - pos.z) * stepWeight;
      stepLength = clamp(stepLength, minStepLength, maxStepLength);

      pos = direction * stepLength + pos;

      currDepth = texture2D(depthtex1, pos.xy).x;
    }

    if(faceVisible()) {
      stepLength = (currDepth - pos.z) * stepWeight;
      pos = direction * stepLength + pos;
      currDepth = texture2D(depthtex1, pos.xy).x;
    }

    if(
      faceVisible() + 0.001 // Not backface.
      && currDepth < 1.0 // Not sky.
      && 0.97 < pos.z // Not camera clipping.
      && onScreen()
      && rayHit
    ) return vec4(texture2D(tex, pos.xy).rgb, 1.0);

    return vec4(0.0);
  }

  // ROUGH REFLECTIONS
  #include "/lib/common/Sky.glsl"

  cv(int) roughSteps = 4;
  cRCP(float, roughSteps);

  vec3 reflectSky(in vec3 direction) {
    return drawSky(direction, 2);
  }

  vec3 raytrace(const vec3 viewDirection, const vec3 viewPosition, vec3 p, in float skyOcclusion) {
    cv(float) quality = 8.0;
    int refines = 4;
    cv(float) maxLength = 1.0 / quality;
    cv(float) minLength = 0.1 / quality;

    vec3 skyReflection = reflectSky(viewDirection) * skyOcclusion;// * max0(dot(viewDirection));

    vec3 direction = normalize(viewToClip(viewPosition + viewDirection) - p);
    float rz = 1.0 / abs(direction.z);

    float stepLength = minLength;
    float depth = p.z;
    bool onScreen = true;

    while(depth >= p.z) {
      stepLength = clamp((depth - p.z) * rz, minLength, maxLength);
      p += direction * stepLength;
      if(clamp01(p) != p) return skyReflection; // Early exit when offscreen
      depth = texture2D(depthtex1, p.xy).x;
    }

    while(refines-->0) {
      p += direction * clamp((depth - p.z) * rz, -stepLength, stepLength);
      depth = texture2D(depthtex1, p.xy).x;
      stepLength *= 0.5;
    }

    bool visible = distance(clipToView(p.xy, depth), clipToView(p.xy, p.z)) < 1.0;

    vec3 terrain = texture2DLod(colortex0, p.xy, 0).rgb;

    return visible ? terrain : skyReflection;
  }

  vec3 MakeSample(float p, float alpha2) {
    cv(float) phi = sqrt(5.0) * 0.5 + 0.5;
    cv(float) goldenAngle = tau / phi / phi;
    cv(float) _y = float(roughSteps) * 64.0 * 64.0 * goldenAngle;

    float x = (alpha2 * p) / (1.0 - p);
    float y = p * _y;

    float c = inversesqrt(x + 1.0);
    float s = sqrt(x) * c;

    return vec3(cos(y) * s, sin(y) * s, c);
  }

  vec3 Fresnel(vec3 f0, float f90, float LoH) {
    return (f90 - f0) * exp2((-5.55473 * LoH - 6.98316) * LoH) + f0;
  }

  float ExactCorrelatedG2(float a, float NoV, float NoL) {
    float x = 2.0 * NoL * NoV + 1e-36;
    return x / mix(x, NoL + NoV + 1e-36, a);
  }

  vec3 raytraceRough(const vec3 screenSpacePosition, const vec3 viewSpacePosition, const vec3 n,const vec3 v, in float roughness, in vec3 f0, in float skyOcclusion) {
    float alpha = roughness * roughness;
    float alpha2 = alpha * alpha;

    float NoV = clamp01(dot(n, v));

    vec3 tangent = normalize(cross(gbufferModelView[1].xyz, n));
    mat3 tbn = mat3(tangent, cross(n, tangent), n);

    float dither = bayer64(gl_FragCoord.xy) * roughStepsRCP;

    vec3 colour = vec3(0.0);

    for(int i = 0; i < roughSteps; i++) {
      vec3 h = tbn * MakeSample((dither + float(i)) * roughStepsRCP, alpha2);
      vec3 l = -reflect(v, h);
      float NoL = clamp01(dot(n, l));
      float VoH = clamp01(dot(v, h));

      colour += raytrace(l, viewSpacePosition, screenSpacePosition, skyOcclusion) * clamp01(Fresnel(f0, 1.0, VoH) * ExactCorrelatedG2(alpha, NoV, NoL));
      //colour += raytraceClip().rgb
    }

    return colour * roughStepsRCP;
  }

#endif /* INTERNAL_INCLUDED_COMMON_RAYTRACER */
