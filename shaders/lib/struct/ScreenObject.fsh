/*
    Jcm2606.
    Halcyon.
    Please read "LICENSE.md" before editing this file.
*/

#if !defined INCLUDED_STRUCT_SCREENOBJECT
    #define INCLUDED_STRUCT_SCREENOBJECT

    struct ScreenObject {
        vec4 tex0;
        vec4 tex1;
        vec4 tex2;
        vec4 tex3;
        vec4 tex4;
        vec4 tex5;
        vec4 tex6;
        vec4 tex7;
    };

    ScreenObject CreateScreenObject(const vec2 screenCoord) {
        ScreenObject screenObject = ScreenObject(vec4(0.0), vec4(0.0), vec4(0.0), vec4(0.0), vec4(0.0), vec4(0.0), vec4(0.0), vec4(0.0));

        #if defined IN_TEX0
            screenObject.tex0 = texture2DLod(colortex0, screenCoord, 0.0);
        #endif

        #if defined IN_TEX1
            screenObject.tex1 = texture2DLod(colortex1, screenCoord, 0.0);
        #endif

        #if defined IN_TEX2
            screenObject.tex2 = texture2DLod(colortex2, screenCoord, 0.0);
        #endif

        #if defined IN_TEX3
            screenObject.tex3 = texture2DLod(colortex3, screenCoord, 0.0);
        #endif

        #if defined IN_TEX4
            screenObject.tex4 = texture2DLod(colortex4, screenCoord, 0.0);
        #endif

        #if defined IN_TEX5
            screenObject.tex5 = texture2DLod(colortex5, screenCoord, 0.0);
        #endif

        #if defined IN_TEX6
            screenObject.tex6 = texture2DLod(colortex6, screenCoord, 0.0);
        #endif

        #if defined IN_TEX7
            screenObject.tex7 = texture2DLod(colortex7, screenCoord, 0.0);
        #endif

        return screenObject;
    }

#endif
