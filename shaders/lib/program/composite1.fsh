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
const bool colortex3MipmapEnabled = true;
const bool colortex4MipmapEnabled = true;

// Varyings.
varying vec2 screenCoord;

flat(vec4) timeVector;

// Screen Samples.
// Uniforms.
uniform sampler2D colortex3;
uniform sampler2D colortex4;

uniform sampler2D depthtex0;
uniform sampler2D depthtex1;

uniform mat4 gbufferProjection, gbufferProjectionInverse;
uniform mat4 gbufferModelView, gbufferModelViewInverse;
uniform mat4 gbufferPreviousModelView;
uniform mat4 gbufferPreviousProjection;

uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;

uniform float frameTime;
uniform float viewWidth;
uniform float viewHeight;

uniform int frameCounter;

// Structs.
#include "/lib/struct/ScreenObject.fsh"

// Globals.
// Includes.
#include "/lib/deferred/TemporalSmoothing.fsh"
#include "/lib/deferred/Camera.fsh"

#include "/lib/deferred/TAA.fsh"

// Functions.
// Main.
void main() {
    ScreenObject screenObject = CreateScreenObject(screenCoord);

    vec4 temporalBuffer = screenObject.tex3;

    float averageLuma = 0.0;
    temporalBuffer.a  = CalculateSmoothedTiles(screenCoord, temporalBuffer.a, averageLuma);

    vec3 image = CalculateTAA(DecodeColour(screenObject.tex4.rgb), screenCoord);
    temporalBuffer.rgb = EncodeColour(image);
    image = CalculateExposedImage(image, averageLuma);
    
    /* DRAWBUFFERS:34 */
    gl_FragData[0] = temporalBuffer;
    gl_FragData[1] = vec4(EncodeColour(image), 1.0);
}
// EOF.
