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

    return refract(viewFront, normal, ior) * dist * 100.0 + viewFront;
  }

  vec3 refractClip(out float dist, in vec3 viewBack, in vec3 viewFront, in vec3 normal, cin(float) ior) {
    return viewToClip(refractView(dist, viewBack, viewFront, normal, ior));
  }

  #if PROGRAM == COMPOSITE0
    vec3 drawRefraction(io GbufferObject gbuffer, io PositionObject position, in vec3 background, in vec2 screenCoord) {
      float dist = 0.0;
      vec3 refractPos = refractClip(dist, position.viewBack, position.viewFront, gbuffer.normal, refractInterfaceAirWater);

      if(dist == 0.0 || texture2D(depthtex1, refractPos.xy).x < position.depthFront) return background;

      return texture2D(colortex0, refractPos.xy).rgb;
    }
  #endif

#endif /* INTERNAL_INCLUDED_DEFERRED_REFRACTION */
