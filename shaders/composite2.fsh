/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#version 120
#extension GL_EXT_gpu_shader4 : enable

#include "/lib/common/syntax/Shaders.glsl"
#define SHADER FSH
#define PROGRAM COMPOSITE2
#include "/lib/Header.glsl"

// CONST
const bool colortex0MipmapEnabled = true;

// USED BUFFERS
#define IN_TEX0

// VARYING
varying vec2 screenCoord;

flat(vec4) timeVector;

// UNIFORM
uniform sampler2D colortex0;
uniform sampler2D colortex3;

uniform float frameTime;

// STRUCT
#include "/lib/common/struct/StructBuffer.glsl"

// ARBITRARY
// INCLUDED FILES
// FUNCTIONS
vec3 computeCameraExposure(io BufferObject buffers) {
  float prevLuma = texture2D(colortex3, screenCoord).r;
  float currLuma = getLuma(texture2DLod(colortex0, vec2(0.5), 100).rgb);
  float avgLuma = mix(prevLuma, currLuma, clamp01(frameTime / (1.0 + frameTime)));

  buffers.tex3.r = avgLuma;

  return buffers.tex0.rgb * (EXPOSURE / max(avgLuma, mix(0.00001, 0.01, timeNight)));
}

// MAIN
void main() {
  // CREATE STRUCTS
  NewBufferObject(buffers);

  // POPULATE STRUCTS
  populateBufferObject(buffers, screenCoord);

  // PERFORM CAMERA EXPOSURE
  buffers.tex0.rgb = computeCameraExposure(buffers);

  // POPULATE OUTGOING BUFFERS
/* DRAWBUFFERS:03 */
  gl_FragData[0] = buffers.tex0;
  gl_FragData[1] = buffers.tex3;
}
