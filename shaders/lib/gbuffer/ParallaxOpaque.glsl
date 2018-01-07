/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_GBUFFER_PARALLAXOPAQUE
  #define INTERNAL_INCLUDED_GBUFFER_PARALLAXOPAQUE

  #if PROGRAM == GBUFFERS_TERRAIN || PROGRAM == GBUFFERS_HAND
    cv(vec3) intervalMult = vec3(1.0, 1.0, 1.0 / PARALLAX_OPAQUE_DEPTH) / TEXTURE_RESOLUTION;
    cv(float) maxOcclusionDistance = 96.0;
    cv(float) minOcclusionDistance = 64.0;
    cv(float) occlusionDistance = maxOcclusionDistance - minOcclusionDistance;
    cRCP(float, occlusionDistance);
    cv(int) maxOcclusionPoints = 
      #ifdef PARALLAX_OPAQUE_QUALITY_SCALING
        int(TEXTURE_RESOLUTION)
      #else
        PARALLAX_OPAQUE_QUALITY_FIXED
      #endif
    ;
    cv(float) minCoord = 1.0 / 4096.0;

    mat2 parallaxDerivatives = mat2(
      dFdx(uvCoord * parallax.zw),
      dFdy(uvCoord * parallax.zw)
    );

    vec4 parallaxSample(in sampler2D tex, in vec2 coord) {
      return texture2DGradARB(tex, fract(coord) * parallax.zw + parallax.xy, parallaxDerivatives[0], parallaxDerivatives[1]);
    }

    vec2 getParallaxCoord(in vec3 view) {
      vec2 uv = uvCoord * parallax.zw + parallax.xy;
      
      #ifndef PARALLAX_OPAQUE
        return uv;
      #endif
      
      if(dist > maxOcclusionDistance) return uv;

      vec3 interval = view * intervalMult;
      vec3 coord = vec3(uvCoord, 1.0);
      float pn = parallaxSample(normals, coord.xy).a;

      for(int i = 0; i < maxOcclusionPoints && pn < coord.p; i++) {
        coord += interval;
      }
      
      if(coord.y < minCoord && parallaxSample(texture, coord.xy).a == 0.0) {
        coord.y = minCoord;
        discard;
      }
      
      if(entity.x == GRASS.x) {
        if(coord.y > 1.0) {
          coord.y = 1.0 - coord.y;
        }
      }

      if(entity.x == CACTUS.x) {
        if(coord.x < 0.0 || coord.x > 1.0) discard;
      }

      uv = mix(fract(coord.xy) * parallax.zw + parallax.xy, uv, clamp01((dist - minOcclusionDistance) * occlusionDistanceRCP));
      
      return uv;
    }
  #endif

#endif /* INTERNAL_INCLUDED_GBUFFER_PARALLAXOPAQUE */
