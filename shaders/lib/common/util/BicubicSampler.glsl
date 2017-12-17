/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_UTIL_BICUBICSAMPLER
  #define INTERNAL_INCLUDED_UTIL_BICUBICSAMPLER

  vec4 bicubic2DLod(in sampler2D tex, in vec2 screenCoord, cin(float) lod) {
    vec2 res = vec2(viewWidth, viewHeight);

    screenCoord = screenCoord * res - 0.5;

    vec2 f = fract(screenCoord);
    screenCoord -= f;

    vec2 f2 = pow2(f);

    vec4 w0 = vec4(0.0);
    vec4 w1 = vec4(0.0);

    w0.xz = 1.0 - f;
    w0.xz *= pow2(w0.xz);

    w1.yw = f2 * f;
    w1.xz = 3.0 * w1.yw + 4.0 - 6.0 * f2;

    w0.yw = 6.0 - w1.xz - w1.yw - w0.xz;

    vec4 s = w0 + w1;
    vec4 c = screenCoord.xxyy + vec2(-0.5, 1.5).xyxy + w1 / s;
    c /= res.xxyy;

    vec2 m = s.xz / (s.xz + s.yw);

    return mix(
      mix(
          texture2DLod(tex, c.yw, lod),
          texture2DLod(tex, c.xw, lod),
        m.x),
      mix(
          texture2DLod(tex, c.yz, lod),
          texture2DLod(tex, c.xz, lod),
        m.x)
    , m.y);
  }

  vec4 bicubic2D(in sampler2D tex, in vec2 screenCoord) {
    return bicubic2DLod(tex, screenCoord, 0.0);
  }
  
#endif /* INTERNAL_INCLUDED_UTIL_BICUBICSAMPLER */
