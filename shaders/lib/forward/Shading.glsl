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

  float getDiffuseShading(in vec3 view, in vec3 normal, in vec3 light, in float roughness, in float f0) {
    return _max0(dot(normal, light));
  }

  vec3 getShadedSurface(in GbufferData gbufferData, in PositionData positionData, in MaskList maskList, in vec3 albedo, in vec2 dither, in mat2x3 atmosphereLighting, out vec4 highlightOcclusion) {
    // CREATE SHADOW DATA INSTANCE
    _newShadowData(shadowData);

    // COMPUTE SHADOWS
    populateShadowData(shadowData, positionData.viewBack, dither, 0.0, false);

    // OUTPUT HIGHLIGHT OCCLUSION
    highlightOcclusion = vec4(mix(vec3(shadowData.occlusionFront), shadowData.colour, shadowData.occlusionDifference), shadowData.occlusionBack);

    // COMPUTE DIRECT COLOUR
    vec3 directColour = atmosphereLighting[0] * shadowData.occlusionBack * mix(vec3(shadowData.occlusionFront), shadowData.colour, shadowData.occlusionDifference);

    // COMPUTE LAYERS OF LIGHTING
    // DIRECT
    vec3 direct  = directColour;
         direct *= getDiffuseShading(positionData.viewBack, normalize(gbufferData.normal), lightDirection, gbufferData.roughness, gbufferData.f0);
         direct *= (maskList.subsurface) ? 0.5 : 1.0;

    // SUBSURFACE
    vec3 subsurface  = directColour;
         subsurface *= _pow(gbufferData.albedo, 0.5);
         subsurface *= float(maskList.subsurface) * 0.5;
         subsurface *= _pow(_max0(dot(normalize(positionData.viewBack), lightDirection)), 6.0) * 4.0 + 1.0;

    // SKY
    vec3 sky  = atmosphereLighting[1];
         sky *= getSkyLightmap(gbufferData.skyLight);

    // BLOCK
    vec3 block  = blockLightColour;
         block *= mix(getBlockLightmap(gbufferData.blockLight), 1.0, _min1(float(maskList.emissive) + gbufferData.emission));

    // COMPUTE SUM OF ALL LIGHTING AND APPLY TO ALBEDO TO GET FINAL SHADED SURFACE
    return albedo * (direct + subsurface + sky + block);
  }

#endif /* INTERNAL_INCLUDED_COMMON_SHADING */
