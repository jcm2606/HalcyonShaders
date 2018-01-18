/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#ifndef INTERNAL_INCLUDED_SYNTAX_POINTMAPPING
  #define INTERNAL_INCLUDED_SYNTAX_POINTMAPPING

  vec2 lattice(in float i, cin(float) n) { return vec2(mod(i * pi, sqrt(n)) * inversesqrt(n), i / n); }

  vec2 spiralMap(float index, float total) {
    float theta = index * tau / (phi * phi);
    return vec2(sin(theta), cos(theta)) * sqrt(index / total);
  }

  vec2 circleMap(in float point) { return vec2(cos(point), sin(point)); }

#endif /* INTERNAL_INCLUDED_SYNTAX_POINTMAPPING */
