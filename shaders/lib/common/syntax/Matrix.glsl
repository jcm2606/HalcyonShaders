/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_SYNTAX_MATRIX
  #define INTERNAL_INCLUDED_SYNTAX_MATRIX

  #define transMAD(mat, v) (mat3(mat) * (v) + (mat)[3].xyz)

  #define diagonal2(mat) vec2((mat)[0].x, (mat)[1].y)
  #define diagonal3(mat) vec3(diagonal2(mat), (mat)[2].z)
  #define diagonal4(mat) vec4(diagonal3(mat), (mat)[2].w)

  #define projMAD3(mat, v) (diagonal3(mat) * (v) + (mat)[3].xyz )
  #define projMAD4(mat, v) (diagonal4(mat) * (v) + (mat)[3].xyzw)
  
  #define deprojectVertex(mat1, mat2, v) (transMAD(mat1, transMAD(mat2, v)))
  #define reprojectVertex(mat, v) (transMAD(mat, v).xyzz * diagonal4(gl_ProjectionMatrix) + gl_ProjectionMatrix[3])

  mat2 rotate2(in float angle) { float a = sin(angle); float b = cos(angle); return mat2(b, -a, a, b); }

#endif /* INTERNAL_INCLUDED_SYNTAX_MATRIX */
