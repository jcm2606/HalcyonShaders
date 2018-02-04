/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#ifndef INTERNAL_INCLUDED_UTIL_NOISE
  #define INTERNAL_INCLUDED_UTIL_NOISE

  vec2 texnoise2D(in sampler2D tex, in vec2 pos) {
    return texture2DLod(tex, fract(pos), 0).xy;
  }
 
  vec2 texnoise2DSmooth(in sampler2D tex, in vec2 pos) {
    vec2 res = vec2(noiseTextureResolution);

    pos *= res;
    pos += 0.5;

    vec2 whole = floor(pos);
    vec2 part = fract(pos);

    part.x = part.x * part.x * (3.0 - 2.0 * part.x);
    part.y = part.y * part.y * (3.0 - 2.0 * part.y);

    pos = whole + part;

    pos -= 0.5;
    pos /= res;

    return texture2D(tex, fract(pos)).xy;
  }

  float texnoise3D(in sampler2D tex, in vec3 pos) {
    float p = floor(pos.z);
    float f = pos.z - p;

    vec2 noise = texture2DLod(tex, fract(pos.xy * noiseTextureResolutionRCP + (p * 17.0 * noiseTextureResolutionRCP)), 0).xy;

    return mix(noise.x, noise.y, f);
  }

  float texnoise3DSmooth(in sampler2D tex, in vec3 pos) {
    float p = floor(pos.z);
    float f = pos.z - p;

    vec2 noise = texnoise2DSmooth(tex, fract(pos.xy * noiseTextureResolutionRCP + (p * 17.0 * noiseTextureResolutionRCP))).xy;

    return mix(noise.x, noise.y, f);
  }

#endif /* INTERNAL_INCLUDED_UTIL_NOISE */
