/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#ifndef INTERNAL_INCLUDED_COMMON_BLOOM
  #define INTERNAL_INCLUDED_COMMON_BLOOM

  #if PROGRAM == COMPOSITE4
    vec3 getBloomTile(in vec2 screenCoord, cin(int) lod, cin(vec2) offset) {
      #ifndef BLOOM
        return vec3(0.0);
      #endif

      cv(float) scale = pow(2.0, lod);

      cv(float) a = pow(0.5, 0.5) * 20.0;
      cv(float) weight = 1.0 / 49.0;

      vec3 tile = vec3(0.0);

      vec2 pixelSize = (1.0 / viewWidth) * vec2(1.0, aspectRatio);

      vec2 coord = screenCoord - offset;
      vec2 scaledCoord = coord * scale;

      if(scaledCoord.x > -0.1 && scaledCoord.y > -0.1 && scaledCoord.x < 1.1 && scaledCoord.y < 1.1) {
        for(int i = 0; i < 49; i++) {
          vec2 sampleCoord = to2D(i, 7);

          float wg = _sqr(1.0 - _length(sampleCoord - vec2(3.0)) * 0.25) * a;

          if(wg <= 0.0) continue;

          tile = texture2DLod(colortex0, (pixelSize * (sampleCoord - vec2(2.5, 3.0)) + coord) * scale, lod).rgb * wg + tile;
        }
      }

      return tile * weight;
    }

    vec3 computeBloomTiles(in vec2 screenCoord) {
      #ifndef BLOOM
        return vec3(0.0);
      #endif

      vec3 tiles = vec3(0.0);

      tiles += getBloomTile(screenCoord, 2, vec2(0.0, 0.0));
      tiles += getBloomTile(screenCoord, 3, vec2(0.3, 0.0));
      tiles += getBloomTile(screenCoord, 4, vec2(0.0, 0.3));
      tiles += getBloomTile(screenCoord, 5, vec2(0.1, 0.3));
      tiles += getBloomTile(screenCoord, 6, vec2(0.2, 0.3));
      tiles += getBloomTile(screenCoord, 7, vec2(0.3, 0.3));

      return tiles;
    }
  #endif

  #if PROGRAM == FINAL
    #include "/lib/sampler/Bicubic.glsl"

    vec3 getBloomTile(in vec2 screenCoord, cin(int) lod, cin(vec2) offset) {
      #ifndef BLOOM
        return vec3(0.0);
      #endif

      cv(float) tilePower = 1.0 / 128.0;

      cv(float) a = 1.0 / pow(2.0, float(lod));
      cv(float) b = pow(9.0 - float(lod), tilePower);

      vec2 halfPixel = 1.0 / vec2(viewWidth, viewHeight) * 0.5;

      return bicubic2D(colortex4, (screenCoord - halfPixel) * a + offset).rgb * b;
    }

    vec3 drawBloom(in vec3 frame, in vec2 screenCoord) {
      #ifndef BLOOM
        return frame;
      #endif

      vec3 bloom = vec3(0.0);

      bloom += getBloomTile(screenCoord, 2, vec2(0.0, 0.0));
      bloom += getBloomTile(screenCoord, 3, vec2(0.3, 0.0));
      bloom += getBloomTile(screenCoord, 4, vec2(0.0, 0.3));
      bloom += getBloomTile(screenCoord, 5, vec2(0.1, 0.3));
      bloom += getBloomTile(screenCoord, 6, vec2(0.2, 0.3));
      bloom += getBloomTile(screenCoord, 7, vec2(0.3, 0.3));

      return mix(
        frame,
        bloom,
        0.01
      );
    }
  #endif

#endif /* INTERNAL_INCLUDED_COMMON_BLOOM */
