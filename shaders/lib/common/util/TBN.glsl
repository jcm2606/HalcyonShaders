/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_UTIL_TBN
  #define INTERNAL_INCLUDED_UTIL_TBN

  mat3 getTBN() {
    vec3 tangent = normalize(at_tangent.xyz / at_tangent.w);
    vec3 normal = normalize(gl_Normal);

    return gl_NormalMatrix * mat3(tangent, cross(tangent, normal), normal);
  }
  
#endif /* INTERNAL_INCLUDED_UTIL_TBN */
