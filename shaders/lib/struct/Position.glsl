/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#ifndef INTERNAL_INCLUDED_STRUCT_POSITION
  #define INTERNAL_INCLUDED_STRUCT_POSITION

  struct PositionData {
    float depthBack;
    float depthFront;

    vec3 viewBack;
    vec3 viewFront;
  };

  #define _newPositionObject(name) PositionData name = PositionData(0.0, 0.0, vec3(0.0), vec3(0.0))

  void populateBackDepth(io PositionData positionData, in vec2 screenCoord) {
    positionData.depthBack = texture2DLod(depthtex1, screenCoord, 0).x;
  }

  void populateFrontDepth(io PositionData positionData, in vec2 screenCoord) {
    positionData.depthFront = texture2DLod(depthtex0, screenCoord, 0).x;
  }

  void populateDepths(io PositionData positionData, in vec2 screenCoord) {
    populateBackDepth(positionData, screenCoord);
    populateFrontDepth(positionData, screenCoord);
  }

#endif /* INTERNAL_INCLUDED_STRUCT_POSITION */
