/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#version 120

#include "/lib/Header.glsl"
#define PROGRAM COMPOSITE0
#define SHADER FSH
#include "/lib/Syntax.glsl"

/* CONST */
const bool colortex4MipmapEnabled = true;

/* USED BUFFER */
#define IN_TEX0
#define IN_TEX1
#define IN_TEX2
#define IN_TEX7

/* VARYING */
varying vec2 screenCoord;

flat(vec3) sunDirection;
flat(vec3) moonDirection;
flat(vec3) lightDirection;
flat(vec3) wLightDirection;

/* UNIFORM */
uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex4;
uniform sampler2D colortex7;

uniform sampler2D depthtex0;
uniform sampler2D depthtex1;

uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;
uniform sampler2D shadowcolor1;

uniform sampler2D noisetex;

uniform mat4 gbufferProjection, gbufferProjectionInverse;
uniform mat4 gbufferModelView, gbufferModelViewInverse;

uniform mat4 shadowProjection, shadowProjectionInverse;
uniform mat4 shadowModelView;

uniform vec3 cameraPosition;

uniform int isEyeInWater;

uniform float sunAngle;
uniform float near;
uniform float far;
uniform float frameTimeCounter;

/* GLOBAL */
/* STRUCT */
#include "/lib/struct/Buffers.glsl"
#include "/lib/struct/Gbuffer.glsl"
#include "/lib/struct/Mask.glsl"
#include "/lib/struct/Position.glsl"

/* INCLUDE */
#include "/lib/deferred/Volumetrics.glsl"

#include "/lib/common/AtmosphereLighting.glsl"

#include "/lib/forward/Shading.glsl"

#include "/lib/common/Clouds.glsl"

#include "/lib/deferred/Refraction.glsl"

/* FUNCTION */
/* MAIN */
void main() {
  // CREATE STRUCT INSTANCES
  _newBufferList(bufferList);
  _newGbufferObject(gbufferData);
  _newMaskList(maskList);
  _newPositionObject(positionData);

  // POPULATE STRUCT INSTANCES
  populateBufferList(bufferList, screenCoord);
  populateGbufferData(gbufferData, bufferList);
  populateMaskList(maskList, gbufferData);
  populateDepths(positionData, screenCoord);
  populateViewPositions(positionData, screenCoord);

  // COMPUTE DITHER
  cv(float) ditherScale = pow(128.0, 2.0);
  vec2 dither = vec2(bayer128(gl_FragCoord.xy), ditherScale);

  // COMPUTE REFRACTION
  float refract_dist = 0.0;
  vec3 refract_hitPosition = vec3(0.0);
  bool refract_isTransparent = false;

  vec4 refract_hitCoord = getRefractedCoord(positionData, screenCoord, gbufferData.normal, 1.0 / 1.333, maskList.water, refract_dist, refract_hitPosition, refract_isTransparent);

  // DRAW REFRACTED BACKGROUND
  bufferList.tex0.rgb = getRefractedBackground(bufferList.tex0.rgb, refract_hitCoord.xy, refract_isTransparent);

  // DRAW CLOUDS
  bufferList.tex0.rgb = drawClouds(bufferList, bufferList.tex0.rgb, screenCoord, refract_hitCoord.xy, refract_isTransparent);

  // COMPUTE ATMOSPHERE LIGHTING
  mat2x3 atmosphereLighting = getAtmosphereLighting();

  // CREATE SHADOW DATA INSTANCE
  _newShadowData(shadowData);

  // COMPUTE SHADOWS
  if(_getLandMask(positionData.depthFront)) computeShadowing(shadowData, positionData.viewFront, dither, 0.0, false);

  // COMPUTE VOLUMETRICS
  computeVolumetrics(positionData, gbufferData, maskList, bufferList.tex6.rgb, bufferList.tex5.rgb, bufferList.tex4.rgb, screenCoord, refract_hitCoord, dither, atmosphereLighting);

  // PUSH TRANSPARENT OBJECTS INTO LINEAR SPACE
  bufferList.tex7.rgb = toLinear(bufferList.tex7.rgb);

  // COMPUTE SHADING ON TRANSPARENT OBJECTS
  vec4 highlightOcclusion = vec4(0.0);
  bufferList.tex7.rgb = getShadedSurface(shadowData, gbufferData, positionData, maskList, bufferList.tex7.rgb, dither, atmosphereLighting, highlightOcclusion);

  // WRITE HIGHLIGHT OCCLUSION TO TEX4 ALPHA
  bufferList.tex4.a = highlightOcclusion.a;

  // POPULATE OUTGOING BUFFERS
  /* DRAWBUFFERS:04567 */
  gl_FragData[0] = bufferList.tex0;
  gl_FragData[1] = bufferList.tex4;
  gl_FragData[2] = bufferList.tex5;
  gl_FragData[3] = bufferList.tex6;
  gl_FragData[4] = bufferList.tex7;
}
