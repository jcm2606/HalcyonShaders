/*
    Jcm2606.
    Halcyon.
    Please read "LICENSE.md" before editing this file.
*/

// Header.
#extension GL_EXT_gpu_shader4 : require

#include "/lib/syntax/Form.glsl"
#define STAGE VSH
#define PROGRAM FINAL
#include "/lib/Syntax.glsl"
#include "/lib/Utility.glsl"
#include "/lib/Settings.glsl"

// Constants.
// Varyings.
varying vec2 screenCoord;

// Screen Samples.
// Uniforms.
// Structs.
// Globals.
// Includes.
// Functions.
// Main.
void main() {
    gl_Position = vec4(gl_Vertex.xy * 2.0 - 1.0, 0.0, 1.0);
    
    screenCoord = gl_Vertex.xy;
}
// EOF.
