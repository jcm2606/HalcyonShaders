/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_COMMON_DEBUGGING
  #define INTERNAL_INCLUDED_COMMON_DEBUGGING

  // SCREEN TILES
  bool isTile(in vec2 screenCoord, in ivec2 tile, cin(int) tiles) {
    cRCP(float, tiles);
    c(int) lastTile = tiles - 1;

    tile = min(tile, lastTile);

    return all(greaterThan(screenCoord, vec2(tilesRCP * tile))) && all(lessThan(screenCoord, vec2(tilesRCP * tile + tilesRCP)));
  }

  #if PROGRAM == FINAL
    vec3 getHDRSlices(in vec3 frame, in vec2 screenCoord) {
      #ifndef VISUALISE_HDR_SLICES
        return frame;
      #else
        c(int) tiles = 5;
        cRCP(float, tiles);

        vec2 tileCoord = fract(screenCoord * tiles);

        if(floor(screenCoord.x * tiles) < 4) return frame;

        vec3 newFrame = texture2D(colortex0, tileCoord).rgb / ( floor(screenCoord.y * tiles) * 8.0 + 1.0 );

        return newFrame;
      #endif
    }
  #endif

#endif /* INTERNAL_INCLUDED_COMMON_DEBUGGING */
