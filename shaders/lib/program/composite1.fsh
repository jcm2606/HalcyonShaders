/*
    Jcm2606.
    Halcyon.
    Please read "LICENSE.md" before editing this file.
*/

// Header.
#extension GL_EXT_gpu_shader4 : require

#include "/lib/syntax/Form.glsl"
#define STAGE FSH
#define PROGRAM COMPOSITE1
#include "/lib/Syntax.glsl"
#include "/lib/Utility.glsl"
#include "/lib/Settings.glsl"

// Used Screen Buffers.
#define IN_TEX3
#define IN_TEX4

// Constants.
const bool colortex4MipmapEnabled = true;

// Varyings.
varying vec2 screenCoord;

flat(vec4) timeVector;

// Screen Samples.
// Uniforms.
uniform sampler2D colortex3;
uniform sampler2D colortex4;

uniform float frameTime;

// Structs.
#include "/lib/struct/ScreenObject.fsh"

// Globals.
// Includes.
#include "/lib/deferred/TemporalSmoothing.fsh"
#include "/lib/deferred/Camera.fsh"

// Functions.
// Main.
void main() {
    ScreenObject screenObject = CreateScreenObject(screenCoord);

    vec4 temporalBuffer = screenObject.tex3;

    float averageLuma = 0.0;
    temporalBuffer.a  = CalculateSmoothedTiles(screenCoord, temporalBuffer.a, averageLuma);

    vec3 image = CalculateExposedImage(DecodeColour(screenObject.tex4.rgb), averageLuma);
    
    /* DRAWBUFFERS:34 */
    gl_FragData[0] = temporalBuffer;
    gl_FragData[1] = vec4(EncodeColour(image), 1.0);
}
// EOF.
