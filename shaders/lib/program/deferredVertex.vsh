// Constants.
// Varyings.
varying vec2 screenCoord;

flat(vec4) timeVector;

flat(vec3) sunDirection;
flat(vec3) moonDirection;
flat(vec3) lightDirection;

// Screen Samples.
// Uniforms.
uniform float sunAngle;

uniform vec3 sunPosition;
uniform vec3 shadowLightPosition;

// Structs.
// Globals.
// Includes.
#include "/lib/util/Time.glsl"

// Functions.
// Main.
void main() {
    gl_Position = vec4(gl_Vertex.xy * 2.0 - 1.0, 0.0, 1.0);
    
    screenCoord = gl_Vertex.xy;

    timeVector = CalculateTimeVector();

    sunDirection = sunPosition * 0.01;
    moonDirection = -sunPosition * 0.01;
    lightDirection = normalize(shadowLightPosition);
}
// EOF.
