/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_STRUCT_STRUCTPOSITION
  #define INTERNAL_INCLUDED_STRUCT_STRUCTPOSITION

  struct PositionObject {
    float depthFront;
    float depthBack;

    vec3 viewPositionFront;
    vec3 viewPositionBack;
  };

  #define NewPositionObject(name) PositionObject name = PositionObject(0.0, 0.0, vec3(0.0), vec3(0.0))

  void populateDepths(io PositionObject position, in vec2 screenCoord) {
    position.depthFront = texture2D(depthtex0, screenCoord).x;
    position.depthBack = texture2D(depthtex1, screenCoord).x;
  }
  
#endif /* INTERNAL_INCLUDED_STRUCT_STRUCTPOSITION */
