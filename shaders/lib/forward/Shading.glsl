/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#ifndef INTERNAL_INCLUDED_COMMON_SHADING
  #define INTERNAL_INCLUDED_COMMON_SHADING

  #include "/lib/common/Shadows.glsl"

  #include "/lib/common/AtmosphereLighting.glsl"

  #include "/lib/common/Lightmaps.glsl"

  #include "/lib/common/Clouds.glsl"

  float getDiffuseShading(in vec3 view, in vec3 normal, in vec3 light, in float roughness, in float f0) {
    return _max0(dot(normal, light));
  }

  vec3 getShadedSurface(in ShadowData shadowData, in GbufferData gbufferData, in PositionData positionData, in MaskList maskList, in vec3 albedo, in vec2 dither, in mat2x3 atmosphereLighting, out vec4 highlightOcclusion) {
    // COMPUTE WORLD POSITION
    vec3 world = viewToWorld(positionData.viewBack);

    // COMPUTE CLOUD SHADOW
    float cloudShadowDirect = getCloudShadow(world + cameraPosition, wLightDirection);

    #ifdef CLOUD_SHADOW_SKY
      float cloudShadowSky = getCloudShadow(world + cameraPosition, vec3(0.0, 1.0, 0.0)) * CLOUD_SHADOW_SKY_INTENSITY + cloudShadowSkyIntensityInverse;
    #else
      cv(float) cloudShadowSky = 1.0;
    #endif

    // COMPUTE DIRECT TINT
    vec3 directTint = mix(vec3(shadowData.occlusionFront), shadowData.colour, saturate(shadowData.occlusionDifference));

    // OUTPUT HIGHLIGHT OCCLUSION
    highlightOcclusion = vec4(directTint, shadowData.occlusionBack * cloudShadowDirect);

    // COMPUTE DIRECT COLOUR
    vec3 directColour = atmosphereLighting[0] * cloudShadowDirect * shadowData.occlusionBack * directTint;

    // COMPUTE LAYERS OF LIGHTING
    // DIRECT
    vec3 direct  = directColour;
         direct *= getDiffuseShading(positionData.viewBack, _normalize(gbufferData.normal), lightDirection, gbufferData.roughness, gbufferData.f0);
         direct *= (maskList.subsurface) ? 0.5 : 1.0;

    // SUBSURFACE
    vec3 subsurface  = directColour;
         subsurface *= sqrt(gbufferData.albedo);
         subsurface *= float(maskList.subsurface) * 0.5;
         subsurface *= _pow(_max0(dot(_normalize(positionData.viewBack), lightDirection)), 6.0) * 4.0 + 1.0;

    // SKY
    vec3 sky  = atmosphereLighting[1];
         sky *= getSkyLightmap(gbufferData.skyLight);
         sky *= cloudShadowSky;

    // BLOCK
    vec3 block  = blockLightColour;
         block *= mix(getBlockLightmap(gbufferData.blockLight), 2.0, _min1(float(maskList.emissive) + gbufferData.emission));

    // COMPUTE SUM OF ALL LIGHTING AND APPLY TO ALBEDO TO GET FINAL SHADED SURFACE
    return albedo * (direct + subsurface + sky + block);
  }

  vec3 getShadedSurface(in GbufferData gbufferData, in PositionData positionData, in MaskList maskList, in vec3 albedo, in vec2 dither, in mat2x3 atmosphereLighting, out vec4 highlightOcclusion) {
    // CREATE SHADOW DATA INSTANCE
    _newShadowData(shadowData);

    // COMPUTE SHADOWS
    computeShadowing(shadowData, positionData.viewBack, dither, 0.0, false);

    // DEFER TO FUNCTION THAT TAKES SHADOW DATA INSTANCE
    return getShadedSurface(shadowData, gbufferData, positionData, maskList, albedo, dither, atmosphereLighting, highlightOcclusion);
  }

#endif /* INTERNAL_INCLUDED_COMMON_SHADING */
