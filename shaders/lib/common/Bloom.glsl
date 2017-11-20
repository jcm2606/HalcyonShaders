/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_COMMON_BLOOM
  #define INTERNAL_INCLUDED_COMMON_BLOOM

  #if PROGRAM == COMPOSITE4
    vec3 generateBloomTile(in vec2 screenCoord, cin(int) lod, cin(vec2) offset) {
      c(float) a = pow(0.5, 0.5) * 20.0;
      c(float) scale = pow(2.0, lod);
      c(float) weight = 1.0 / 49.0;

      vec3 tile = vec3(0.0);

      vec2 pixelSize = (1.0 / vec2(viewWidth, viewHeight)).x * vec2(1.0, aspectRatio);

      vec2 coord = screenCoord - offset;
      vec2 scaledCoord = coord * scale;

      if(scaledCoord.x > -0.1 && scaledCoord.y > -0.1 && scaledCoord.x < 1.1 && scaledCoord.y < 1.1) {
        for(int i = 0; i < 7; i++) {
          for(int j = 0; j < 7; j++) {
            float wg = pow2((1.0 - flength(vec2(i - 3, j - 3)) * 0.25)) * a;

            if(wg <= 0.0) continue;

            tile = texture2DLod(colortex0, (pixelSize * vec2(i - 2.5, j - 3) + coord) * scale, lod).rgb * wg + tile;
          }
        }
      }

      return tile * weight;
    }

    vec3 generateBloomTiles(in vec2 screenCoord) {
      vec3 tiles = vec3(0.0);

      tiles += generateBloomTile(screenCoord, 2, vec2(0.0, 0.0));
      tiles += generateBloomTile(screenCoord, 3, vec2(0.3, 0.0));
      tiles += generateBloomTile(screenCoord, 4, vec2(0.0, 0.3));
      tiles += generateBloomTile(screenCoord, 5, vec2(0.1, 0.3));
      tiles += generateBloomTile(screenCoord, 6, vec2(0.2, 0.3));
      tiles += generateBloomTile(screenCoord, 7, vec2(0.3, 0.3));

      return tiles;
    }
  #endif

  #if PROGRAM == FINAL
    vec3 drawBloomTile(in vec2 screenCoord, cin(int) lod, cin(vec2) offset) {
      c(float) tilePower = 0.0625;

      c(float) a = 1.0 / pow(2.0, float(lod));
      c(float) b = pow(9.0 - float(lod), tilePower);

      vec2 halfPixel = 1.0 / vec2(viewWidth, viewHeight) * 0.5;

      return texture2D(colortex4, (screenCoord - halfPixel) * a + offset).rgb * b;
    }

    vec3 drawBloom(in vec3 frame, in vec2 screenCoord) {
      vec3 bloom = vec3(0.0);
      
      bloom += drawBloomTile(screenCoord, 2, vec2(0.0, 0.0));
      bloom += drawBloomTile(screenCoord, 3, vec2(0.3, 0.0));
      bloom += drawBloomTile(screenCoord, 4, vec2(0.0, 0.3));
      bloom += drawBloomTile(screenCoord, 5, vec2(0.1, 0.3));
      bloom += drawBloomTile(screenCoord, 6, vec2(0.2, 0.3));
      bloom += drawBloomTile(screenCoord, 7, vec2(0.3, 0.3));

      return mix(frame, bloom, 0.02 * 0.5);
    }
  #endif

#endif /* INTERNAL_INCLUDED_COMMON_BLOOM */
