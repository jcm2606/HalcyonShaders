/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_STRUCT_BUFFER
  #define INTERNAL_INCLUDED_STRUCT_BUFFER

  struct BufferObject {
    vec4 tex0;
    vec4 tex1;
    vec4 tex2;
    vec4 tex3;
    vec4 tex4;
    vec4 tex5;
    vec4 tex6;
    vec4 tex7;
  };

  #define NewBufferObject(name) BufferObject name = BufferObject(vec4(0.0), vec4(0.0), vec4(0.0), vec4(0.0), vec4(0.0), vec4(0.0), vec4(0.0), vec4(0.0))

  void populateBufferObject(io BufferObject buffers, in vec2 screenCoord) {
    #ifdef IN_TEX0
      buffers.tex0 = texture2D(colortex0, screenCoord);
    #else
      buffers.tex0 = vec4(0.0);
    #endif

    #ifdef IN_TEX1
      buffers.tex1 = texture2D(colortex1, screenCoord);
    #else
      buffers.tex1 = vec4(0.0);
    #endif

    #ifdef IN_TEX2
      buffers.tex2 = texture2D(colortex2, screenCoord);
    #else
      buffers.tex2 = vec4(0.0);
    #endif

    #ifdef IN_TEX3
      buffers.tex3 = texture2D(colortex3, screenCoord);
    #else
      buffers.tex3 = vec4(0.0);
    #endif

    #ifdef IN_TEX4
      buffers.tex4 = texture2D(colortex4, screenCoord);
    #else
      buffers.tex4 = vec4(0.0);
    #endif

    #ifdef IN_TEX5
      buffers.tex5 = texture2D(colortex5, screenCoord);
    #else
      buffers.tex5 = vec4(0.0);
    #endif

    #ifdef IN_TEX6
      buffers.tex6 = texture2D(colortex6, screenCoord);
    #else
      buffers.tex6 = vec4(0.0);
    #endif

    #ifdef IN_TEX7
      buffers.tex7 = texture2D(colortex7, screenCoord);
    #else
      buffers.tex7 = vec4(0.0);
    #endif
  }

#endif /* INTERNAL_INCLUDED_STRUCT_BUFFER */
