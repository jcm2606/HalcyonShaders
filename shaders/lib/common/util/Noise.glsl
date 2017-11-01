/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
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

  c(vec3) hashScale = vec3(0.1031, 0.1030, 0.0973);

  float hash13(in vec3 pos) {
    pos  = fract(pos * hashScale.x);
    pos += dot(pos, pos.yzx + 19.19);
    return fract((pos.x + pos.y) * pos.z);
  }

  vec3 hash33(in vec3 pos) {
    pos  = fract(pos * hashScale);
    pos += dot(pos, pos.yzx + 19.19);
    return fract((pos.xxy + pos.yxx) * pos.zyx);
  }

  float hash12(in vec2 pos) {
    pos  = fract(pos * hashScale.x);
    pos += dot(pos, pos.yx + 19.19);
    return fract((pos.x + pos.y) * pos.x);
  }

  vec2 hash22(in vec2 pos) {
    pos  = fract(pos * hashScale.xy);
    pos += dot(pos, pos.yx + 19.19);
    return fract((pos.xx + pos.yx) * pos.xy);
  }

  float simplex2D(vec2 p ){
    vec2 s = floor( p + dot(p,vec2(.3660254037844386)));
    vec2 x = p - s + dot(s,vec2(.21132486540518713));
    
    vec2 i1 = step(x.yx,x.xy);    
    vec2 x1 = x - i1 + .21132486540518713;
    vec2 x2 = x - .5773502691896257;
    
    vec3 w = vec3(dot(x,x), dot(x1,x1), dot(x2,x2));

    w = clamp( 0.5-w, 0. ,1.);
    w*=w;
    w*=w;

    vec3 d = vec3(
      dot(hash22(s   )-.5,x ),
      dot(hash22(s+i1)-.5,x1),
      dot(hash22(s+1.)-.5,x2)
    );

    return dot( d, w*140. );
  }

  float simplex3D(vec3 p) {
    vec3 s = floor(p + dot(p, vec3(0.3333333)));
    vec3 x = p - s + dot(s, vec3(0.1666666));

    vec3 e = step(x.yzx, x.xyz);
    e -= e.zxy;

    vec3 i1 = clamp(e   ,0.,1.);
    vec3 i2 = clamp(e+1.,0.,1.);

    vec3 x1 = x - i1 + .1666666;
    vec3 x2 = x - i2 + .3333333;
    vec3 x3 = x - .5;

    vec4 w = vec4(
      dot(x , x ),
      dot(x1, x1),
      dot(x2, x2),
      dot(x3, x3));
    
    w = clamp(.6 - w,0.,1.);
    w *= w;
    w *= w;
    
    vec4 d=vec4(
      dot(hash33(s     )-.5, x ),
      dot(hash33(s + i1)-.5, x1),
      dot(hash33(s + i2)-.5, x2),
      dot(hash33(s + 1.)-.5, x3));

    return dot(d, w*52.);
  } 

#endif /* INTERNAL_INCLUDED_UTIL_NOISE */
