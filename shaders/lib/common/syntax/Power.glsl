/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_SYNTAX_POWER
  #define INTERNAL_INCLUDED_SYNTAX_POWER

  #define powi(n, i) pow##i(n)

  float pow2(in float n)  { return n * n; }
  float pow3(in float n)  { return pow2(n) * n; }
  float pow4(in float n)  { return pow2(pow2(n)); }
  float pow5(in float n)  { return pow2(pow2(n)) * n; }
  float pow6(in float n)  { return pow2(pow2(n) * n); }
  float pow7(in float n)  { return pow2(pow2(n) * n) * n; }
  float pow8(in float n)  { return pow2(pow2(pow2(n))); }
  float pow9(in float n)  { return pow2(pow2(pow2(n))) * n; }
  float pow10(in float n) { return pow2(pow2(pow2(n)) * n); }
  float pow11(in float n) { return pow2(pow2(pow2(n)) * n) * n; }
  float pow12(in float n) { return pow2(pow2(pow2(n) * n)); }
  float pow13(in float n) { return pow2(pow2(pow2(n) * n)) * n; }
  float pow14(in float n) { return pow2(pow2(pow2(n) * n) * n); }
  float pow15(in float n) { return pow2(pow2(pow2(n) * n) * n) * n; }
  float pow16(in float n) { return pow2(pow2(pow2(pow2(n)))); }

  vec2 pow2(in vec2 n)  { return n * n; }
  vec2 pow3(in vec2 n)  { return pow2(n) * n; }
  vec2 pow4(in vec2 n)  { return pow2(pow2(n)); }
  vec2 pow5(in vec2 n)  { return pow2(pow2(n)) * n; }
  vec2 pow6(in vec2 n)  { return pow2(pow2(n) * n); }
  vec2 pow7(in vec2 n)  { return pow2(pow2(n) * n) * n; }
  vec2 pow8(in vec2 n)  { return pow2(pow2(pow2(n))); }
  vec2 pow9(in vec2 n)  { return pow2(pow2(pow2(n))) * n; }
  vec2 pow10(in vec2 n) { return pow2(pow2(pow2(n)) * n); }
  vec2 pow11(in vec2 n) { return pow2(pow2(pow2(n)) * n) * n; }
  vec2 pow12(in vec2 n) { return pow2(pow2(pow2(n) * n)); }
  vec2 pow13(in vec2 n) { return pow2(pow2(pow2(n) * n)) * n; }
  vec2 pow14(in vec2 n) { return pow2(pow2(pow2(n) * n) * n); }
  vec2 pow15(in vec2 n) { return pow2(pow2(pow2(n) * n) * n) * n; }
  vec2 pow16(in vec2 n) { return pow2(pow2(pow2(pow2(n)))); }

  vec3 pow2(in vec3 n)  { return n * n; }
  vec3 pow3(in vec3 n)  { return pow2(n) * n; }
  vec3 pow4(in vec3 n)  { return pow2(pow2(n)); }
  vec3 pow5(in vec3 n)  { return pow2(pow2(n)) * n; }
  vec3 pow6(in vec3 n)  { return pow2(pow2(n) * n); }
  vec3 pow7(in vec3 n)  { return pow2(pow2(n) * n) * n; }
  vec3 pow8(in vec3 n)  { return pow2(pow2(pow2(n))); }
  vec3 pow9(in vec3 n)  { return pow2(pow2(pow2(n))) * n; }
  vec3 pow10(in vec3 n) { return pow2(pow2(pow2(n)) * n); }
  vec3 pow11(in vec3 n) { return pow2(pow2(pow2(n)) * n) * n; }
  vec3 pow12(in vec3 n) { return pow2(pow2(pow2(n) * n)); }
  vec3 pow13(in vec3 n) { return pow2(pow2(pow2(n) * n)) * n; }
  vec3 pow14(in vec3 n) { return pow2(pow2(pow2(n) * n) * n); }
  vec3 pow15(in vec3 n) { return pow2(pow2(pow2(n) * n) * n) * n; }
  vec3 pow16(in vec3 n) { return pow2(pow2(pow2(pow2(n)))); }

#endif /* INTERNAL_INCLUDED_SYNTAX_POWER */
