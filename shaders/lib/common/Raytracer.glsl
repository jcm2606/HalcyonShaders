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

  cv(int) quality = 8;
  cRCP(float, quality);
  cv(int) steps = quality + 4;

  vec4 raytraceClip(in sampler2D tex, in vec3 dir, in vec3 view) {
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

#endif /* INTERNAL_INCLUDED_COMMON_RAYTRACER */
