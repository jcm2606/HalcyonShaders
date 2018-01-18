/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#ifndef INTERNAL_INCLUDED_STRUCT_BUFFERS
  #define INTERNAL_INCLUDED_STRUCT_BUFFERS

  struct BufferList {
    vec4 tex0;
    vec4 tex1;
    vec4 tex2;
    vec4 tex3;
    vec4 tex4;
    vec4 tex5;
    vec4 tex6;
    vec4 tex7;
  };

  #define _newBufferList(name) BufferList name = BufferList(vec4(0.0), vec4(0.0), vec4(0.0), vec4(0.0), vec4(0.0), vec4(0.0), vec4(0.0), vec4(0.0))

  void populateBufferList(io BufferList bufferList, in vec2 screenCoord) {
    #ifdef IN_TEX0
      bufferList.tex0 = texture2DLod(colortex0, screenCoord, 0);
    #endif

    #ifdef IN_TEX1
      bufferList.tex1 = texture2DLod(colortex1, screenCoord, 0);
    #endif

    #ifdef IN_TEX2
      bufferList.tex2 = texture2DLod(colortex2, screenCoord, 0);
    #endif

    #ifdef IN_TEX3
      bufferList.tex3 = texture2DLod(colortex3, screenCoord, 0);
    #endif

    #ifdef IN_TEX4
      bufferList.tex4 = texture2DLod(colortex4, screenCoord, 0);
    #endif

    #ifdef IN_TEX5
      bufferList.tex5 = texture2DLod(colortex5, screenCoord, 0);
    #endif

    #ifdef IN_TEX6
      bufferList.tex6 = texture2DLod(colortex6, screenCoord, 0);
    #endif

    #ifdef IN_TEX7
      bufferList.tex7 = texture2DLod(colortex7, screenCoord, 0);
    #endif
  }

#endif /* INTERNAL_INCLUDED_STRUCT_BUFFERS */
