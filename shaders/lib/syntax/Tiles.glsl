/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#ifndef INTERNAL_INCLUDED_SYNTAX_TILES
  #define INTERNAL_INCLUDED_SYNTAX_TILES

  bool canWriteTo(in vec2 screenCoord, ivec2 tile, cin(int) width) {
    cRCP(float, width);
    cv(int) lastTile = width - 1;

    tile = min(tile, lastTile);

    return all(greaterThan(screenCoord, vec2(widthRCP * tile))) && all(lessThan(screenCoord, vec2(widthRCP * tile + widthRCP)));
  }

  vec4 readFromTile(in sampler2D tex, cin(ivec2) tile, cin(int) width) {
    cRCP(float, width);
    cv(vec2) xy = (tile + vec2(0.5)) * widthRCP;

    return texture2D(tex, xy);
  }

#endif /* INTERNAL_INCLUDED_SYNTAX_TILES */
