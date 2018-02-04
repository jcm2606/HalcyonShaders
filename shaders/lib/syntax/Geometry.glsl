/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#ifndef INTERNAL_INCLUDED_SYNTAX_FUNCTIONS
  #define INTERNAL_INCLUDED_SYNTAX_FUNCTIONS

  // SPHERE
  float sdfSphere(in vec3 O, in vec3 P, in float r) {
    return length(P - O) - r;
  }

  bool intersectSphere(in vec3 rayOrigin, in vec3 rayDirection, in vec3 sphereOrigin, in float sphereRadius, inout vec3 intersection0, inout vec3 intersection1) {
    vec3 L = sphereOrigin - rayOrigin;

    //if(sdfSphere(sphereOrigin, rayOrigin) < 0.0) return false; 

    float tca = dot(L, rayDirection);

    if(tca < 0.0) return false;

    float d2 = dot(L, L) - tca * tca;
    float r2 = sphereRadius * sphereRadius;

    if(d2 > r2) return false;

    float tch = sqrt(r2 - d2);

    intersection0 = rayDirection * (tca - tch) + rayOrigin;
    intersection1 = rayDirection * (tca + tch) + rayOrigin;

    return true;
  }

#endif /* INTERNAL_INCLUDED_SYNTAX_FUNCTIONS */
