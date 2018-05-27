/*
    Jcm2606.
    Halcyon.
    Please read "LICENSE.md" before editing this file.
*/

// Header.
#extension GL_EXT_gpu_shader4 : require

#include "/lib/syntax/Form.glsl"
#define STAGE FSH
#define PROGRAM FINAL
#include "/lib/Syntax.glsl"
#include "/lib/Utility.glsl"
#include "/lib/Settings.glsl"

// Used Screen Buffers.
#define IN_TEX4

// Constants.
// Varyings.
varying vec2 screenCoord;

flat(vec4) timeVector;

// Screen Samples.
// Uniforms.
uniform sampler2D colortex3;
uniform sampler2D colortex2;
uniform sampler2D colortex4;

uniform float viewWidth;
uniform float viewHeight;

// Structs.
#include "/lib/struct/ScreenObject.fsh"

// Globals.
// Includes.
#include "/lib/common/Bloom.fsh"

// Functions.
// Main.
void main() {
    ScreenObject screenObject = CreateScreenObject(screenCoord);

    vec3 image = DecodeColour(screenObject.tex4.rgb);
         image = CalculateBloom(image, screenCoord);
         image = image / (1.0 + image);
        
    gl_FragColor = vec4(ToGamma(image), 1.0);
}
// EOF.
