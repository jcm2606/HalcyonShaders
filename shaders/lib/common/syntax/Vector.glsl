/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_SYNTAX_VECTOR
  #define INTERNAL_INCLUDED_SYNTAX_VECTOR

  cv(vec2) swizzle2 = vec2(1.0, 0.0);
  cv(vec3) swizzle3 = vec3(1.0, 0.0, 0.5);
  cv(vec4) swizzle4 = vec4(1.0, 0.0, 0.5, -1.0);

  #define reverse2(v) v.yx
  #define reverse3(v) v.zyx
  #define reverse4(v) v.wzyx

  void swap2(io vec2 a, io vec2 b) {
    vec2 c = a;
    a = b;
    b = c;
  }

  float flengthsqr(in vec2 n) { return dot(n, n); }
  float flengthsqr(in vec3 n) { return dot(n, n); }
  float flengthsqr(in vec4 n) { return dot(n, n); }
  
  float flength(in vec2 n) { return sqrt(flengthsqr(n)); }
  float flength(in vec3 n) { return sqrt(flengthsqr(n)); }
  float flength(in vec4 n) { return sqrt(flengthsqr(n)); }

  float flengthinv(in vec2 n) { return sqrt(flengthsqr(n)); }
  float flengthinv(in vec3 n) { return sqrt(flengthsqr(n)); }
  float flengthinv(in vec4 n) { return sqrt(flengthsqr(n)); }

  vec2 fnormalize(in vec2 n) { return n * flengthinv(n); }
  vec3 fnormalize(in vec3 n) { return n * flengthinv(n); }
  vec4 fnormalize(in vec4 n) { return n * flengthinv(n); }

#endif /* INTERNAL_INCLUDED_SYNTAX_VECTOR */
