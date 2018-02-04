/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#ifndef INTERNAL_INCLUDED_COMMON_REFLECTIONS
  #define INTERNAL_INCLUDED_COMMON_REFLECTIONS

  #include "/lib/util/SpaceConversion.glsl"

  #include "/lib/common/Raytracer.glsl"

  #include "/lib/common/AtmosphereLighting.glsl"

  #include "/lib/common/Specular.glsl"

  vec3 drawReflections(in GbufferData gbufferData, in PositionData positionData, in vec3 diffuse, in vec2 screenCoord, in mat2x3 atmosphereLighting, in vec4 highlightTint, in vec2 dither) {
    // DEFINE DATA
    vec3 viewDirection = -_normalize(positionData.viewFront);
    vec3 normal = _normalize(gbufferData.normal);

    // COMPUTE METALLIC MASK
    float metalness = float(gbufferData.f0 > 0.5);

    // PERFORM ROUGH RAYTRACE
    vec3 specular = raytraceRough(vec3(screenCoord, positionData.depthFront), positionData.viewFront, normal, viewDirection, gbufferData.roughness, vec3(gbufferData.f0), pow(_min1(gbufferData.skyLight * 1.1), 6.0), dither);

    // COMPUTE SPECULAR HIGHLIGHT
    // TODO: Cloud shadow.
    specular += atmosphereLighting[0] * highlightTint.rgb * highlightTint.a * clamp(GGX(viewDirection, lightDirection, normal, gbufferData.roughness, gbufferData.f0), 0.0, SUN_LIGHT_INTENSITY);

    // APPLY METALLIC TINT
    if(metalness > 0.5) specular *= gbufferData.albedo;

    return diffuse * (1.0 - metalness) + specular;
  }

#endif /* INTERNAL_INCLUDED_COMMON_REFLECTIONS */
