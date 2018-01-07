/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_DEFERRED_REFRACTION
  #define INTERNAL_INCLUDED_DEFERRED_REFRACTION

  vec3 refractView(out float dist, in vec3 viewBack, in vec3 viewFront, in vec3 normal, cin(float) ior) {
    dist = distance(viewBack, viewFront);

    if(dist == 0.0) return viewFront;

    return refract(normalize(viewFront), normalize(normal), ior) * 2.0 * clamp01(dist) + (viewFront);
  }

  vec3 refractClip(out float dist, in vec3 viewBack, in vec3 viewFront, in vec2 screenCoord, in vec3 normal, cin(float) ior) {
    vec3 refractedClip = viewToClip(refractView(dist, viewBack, viewFront, normal, ior));

    refractedClip.y = mix(
      refractedClip.y,
      screenCoord.y,
      smoothstep(0.7, 1.0, 1.0 - refractedClip.y) + smoothstep(0.7, 1.0, refractedClip.y)
    );

    refractedClip.x = mix(
      refractedClip.x,
      screenCoord.x,
      smoothstep(0.9, 1.0, abs(refractedClip.x * 2.0 - 1.0))
    );

    return refractedClip;
  }

  vec3 drawRefraction(io GbufferObject gbuffer, io PositionObject position, in vec3 background, in vec2 screenCoord) {
    float dist = 0.0;
    vec3 refractPos = refractClip(dist, position.viewBack, position.viewFront, screenCoord, gbuffer.normal, refractInterfaceAirWater);

    if(dist == 0.0 || texture2D(depthtex1, refractPos.xy).x < position.depthFront) return background;

    return texture2D(colortex0, refractPos.xy).rgb;
  }

#endif /* INTERNAL_INCLUDED_DEFERRED_REFRACTION */
