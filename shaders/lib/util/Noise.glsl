/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#ifndef INTERNAL_INCLUDED_UTIL_NOISE
  #define INTERNAL_INCLUDED_UTIL_NOISE

  float texnoise2D(in sampler2D tex, in vec2 pos) {
    return texture2DLod(tex, fract(pos), 0).x;
  }

  float texnoise3D(in sampler2D tex, in vec3 pos) {
    float p = floor(pos.z);
    float f = pos.z - p;

    float zStretch = 17.0 * noiseTextureResolutionRCP;

    vec2 coord = pos.xy * noiseTextureResolutionRCP + (p * zStretch);

    float xy1 = texture2DLod(tex, fract(coord), 0).x;
    float xy2 = texture2DLod(tex, fract(coord) + zStretch, 0).x;

    return mix(xy1, xy2, f);
  }

#endif /* INTERNAL_INCLUDED_UTIL_NOISE */
