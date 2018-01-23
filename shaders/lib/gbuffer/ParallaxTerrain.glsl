/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#ifndef INTERNAL_INCLUDED_GBUFFER_PARALLAXTERRAIN
  #define INTERNAL_INCLUDED_GBUFFER_PARALLAXTERRAIN

  #if PROGRAM == GBUFFERS_TERRAIN || PROGRAM == GBUFFERS_HAND
    #define tileSize     tileInfo[0]
    #define tilePosition tileInfo[1]

    #define wrapTexture(p) ( mod(p, tileSize) + tilePosition )
    
    cv(int) parallaxSamples = PARALLAX_TERRAIN_SAMPLES;
    cRCP(float, parallaxSamples);

    cv(float) parallaxDepth = PARALLAX_TERRAIN_DEPTH;
    cRCP(float, parallaxDepth);

    vec4 parallax_sampleTexture(in sampler2D tex, in vec2 p, in mat2 texD) {
      float parallaxDepth = tileSize.x * parallaxDepthRCP;

      return texture2DGradARB(tex, wrapTexture(p), texD[0], texD[1]);
    }

    float getDepthGrad(in vec2 p, in mat2 texD) {
      float parallaxDepth = tileSize.x * parallaxDepthRCP;

      return texture2DGradARB(normals, wrapTexture(p), texD[0], texD[1]).a * parallaxDepth - parallaxDepth;
    }

    vec2 getParallaxCoord(in vec2 coord, in vec3 view, in mat2 texD) {
      #ifndef PARALLAX_TERRAIN
        return coord;
      #endif

      if(_isGroundFoliage(entity.x) || entity.x == GLASS.x || entity.x == GLASS.y) return coord;

      float stepLength = tileSize.x * parallaxSamplesRCP;

      vec3 p = vec3(coord, 0.0);
      int i = parallaxSamples;

      while(getDepthGrad(p.xy, texD) < p.z && i-- > 0) {
        p += view * stepLength;
      }

      return wrapTexture(p.xy);
    }
  #endif

#endif /* INTERNAL_INCLUDED_GBUFFER_PARALLAXTERRAIN */
