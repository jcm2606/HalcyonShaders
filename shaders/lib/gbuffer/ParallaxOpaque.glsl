/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_GBUFFER_PARALLAXOPAQUE
  #define INTERNAL_INCLUDED_GBUFFER_PARALLAXOPAQUE

  #if PROGRAM == GBUFFERS_TERRAIN || PROGRAM == GBUFFERS_HAND
    c(vec3) intervalMult = vec3(1.0, 1.0, 1.0 / PARALLAX_OPAQUE_DEPTH) / TEXTURE_RESOLUTION;
    c(float) maxOcclusionDistance = 96.0;
    c(float) minOcclusionDistance = 64.0;
    c(float) occlusionDistance = maxOcclusionDistance - minOcclusionDistance;
    cRCP(float, occlusionDistance);
    c(int) maxOcclusionPoints = 
      #ifdef PARALLAX_OPAQUE_QUALITY_SCALING
        int(TEXTURE_RESOLUTION)
      #else
        PARALLAX_OPAQUE_QUALITY_FIXED
      #endif
    ;
    c(float) minCoord = 1.0 / 4096.0;

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

      for(int i = 0; i < maxOcclusionPoints && parallaxSample(normals, coord.xy).a < coord.p; i++) {
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

      uv = mix(fract(coord.xy) * parallax.zw + parallax.xy, uv, clamp01((dist - minOcclusionDistance) * occlusionDistanceRCP));
      
      return uv;
    }
  #endif

#endif /* INTERNAL_INCLUDED_GBUFFER_PARALLAXOPAQUE */
