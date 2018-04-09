/*
    Jcm2606.
    Halcyon.
    Please read "LICENSE.md" before editing this file.
*/

// Header.
#extension GL_EXT_gpu_shader4 : require

#include "/lib/syntax/Form.glsl"
#define STAGE FSH
#define PROGRAM COMPOSITE2
#include "/lib/Syntax.glsl"
#include "/lib/Utility.glsl"
#include "/lib/Settings.glsl"

// Used Screen Buffers.
#define IN_TEX4

// Constants.
// Varyings.
varying vec2 screenCoord;

// Screen Samples.
// Uniforms.
uniform sampler2D colortex4;

// Structs.
#include "/lib/struct/ScreenObject.fsh"

// Globals.
// Includes.
// Functions.
// Main.
void main() {
    ScreenObject screenObject = CreateScreenObject(screenCoord);

    vec3 image = DecodeColour(screenObject.tex4.rgb);
    
    /* DRAWBUFFERS:4 */
    gl_FragData[0] = vec4(EncodeColour(image), 1.0);
}
// EOF.
