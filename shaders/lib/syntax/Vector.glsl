/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#ifndef INTERNAL_INCLUDED_SYNTAX_VECTOR
  #define INTERNAL_INCLUDED_SYNTAX_VECTOR

  cv(vec2) swizzle2 = vec2(1.0, 0.0);
  cv(vec3) swizzle3 = vec3(1.0, 0.0, 0.5);
  cv(vec4) swizzle4 = vec4(1.0, 0.0, 0.5, -1.0);

  #define _reverse2(x) x.yx
  #define _reverse3(x) x.zyx
  #define _reverse4(x) x.wzyx

  void swap2(io vec2 a, io vec2 b) {
    vec2 c = a;
    a = b;
    b = c;
  }

#endif /* INTERNAL_INCLUDED_SYNTAX_VECTOR */
