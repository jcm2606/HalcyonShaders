/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_COMMON_REFLECTIONS
  #define INTERNAL_INCLUDED_COMMON_REFLECTIONS

  #ifndef INTERNAL_INCLUDED_COMMON_RAYTRACER
    #include "/lib/common/Raytracer.glsl"
  #endif

  #ifndef INTERNAL_INCLUDED_COMMON_SKY
    #include "/lib/common/Sky.glsl"
  #endif

  #ifndef INTERNAL_INCLUDED_COMMON_ATMOSPHERELIGHTING
    #include "/lib/common/AtmosphereLighting.glsl"
  #endif

  vec3 halfVector(in vec3 a, in vec3 b) {
    return normalize(a - b);
  }

  float fresnelSchlick(in float angle, in float f0) {
    return (1.0 - f0) * pow5(1.0 - max0(angle)) + f0;
  }

  float ggx(in vec3 view, in vec3 normal, in vec3 light, in float roughness, in float f0) {
    roughness = clamp(roughness, 0.05, 0.99);

    float alpha = pow2(roughness);

    vec3 halfVector = halfVector(light, view);

    float alphaSqr = pow2(alpha);

    float k2 = pow2(alpha);

    return max0(dot(normal, light)) * alphaSqr / (pi * pow2(pow2(max0(dot(normal, halfVector))) * (alphaSqr - 1.0) + 1.0)) * fresnelSchlick(dot(halfVector, light), f0) / (pow2(max0(dot(light, halfVector))) * (1.0 - k2) + k2);
  }

  vec3 sunMRP(in vec3 normal, in vec3 view, in vec3 light) {
    vec3 reflected = reflect(view, normal);

    cv(float) radius = 0.01 * SUN_SIZE;
    float d = cos(radius);

    float LdotR = dot(light, reflected);

    return (LdotR < d) ? normalize(d * light + (normalize(reflected - LdotR * light) * sin(radius))) : reflected;
  }

  vec4 getReflections(in vec2 screenCoord, in float depth, in vec3 view, in vec3 albedo, in vec3 normal, in float roughness, in float f0, in float skyOcclusion, in mat2x3 atmosphereLighting, in vec4 highlightTint) {
    // CREATE DATA
    vec3 nview = normalize(view);
    vec3 nnormal = normalize(normal);
    vec3 dir = -nview;
    vec2 alpha = pow2(vec2(roughness * 2.45, roughness * 1.6));
    float metallic = (f0 > 0.5) ? 1.0 : 0.0;

    // CREATE REFLECTION VECTORS
    vec3 reflView = reflect(nview, nnormal);

    // RAYTRACE
    //vec4 specular = raytraceClip(tex, -reflect(dir, nnormal), view);
    vec3 specular = raytraceRough(vec3(screenCoord, depth), view, nnormal, dir, roughness, vec3(f0), skyOcclusion);

    // APPLY FRESNEL
    float fresnel = ((1.0 - f0) * pow5(1.0 - max0(dot(dir, normalize(reflView + dir)))) + f0) * max0(1.0 - alpha.x);

    // APPLY SPECULAR HIGHLIGHT
    float highlight = ggx(nview, nnormal, sunMRP(nnormal, nview, lightVector), roughness, f0);

    #if PROGRAM == DEFERRED2
      highlight *= getCloudShadow(viewToWorld(view) + cameraPosition, wLightVector);
    #endif

    specular += min(vec3(SUN_BRIGHTNESS), atmosphereLighting[0] * highlight * highlightTint.rgb * highlightTint.a);

    // APPLY METALLIC TINTING
    if(metallic > 0.5) specular *= albedo;

    return vec4(specular, fresnel);
  }

  vec3 drawReflectionOnSurface(in vec4 diffuse, in vec2 screenCoord, in float depth, in vec3 view, in vec3 albedo, in vec3 normal, in float roughness, in float f0, in float skyOcclusion, in mat2x3 atmosphereLighting, in vec4 highlightTint) {
    return diffuse.rgb * ((f0 > 0.5) ? 0.0 : 1.0) + getReflections(screenCoord, depth, view, albedo, normal, roughness, f0, skyOcclusion, atmosphereLighting, highlightTint).rgb;
  }

#endif /* INTERNAL_INCLUDED_COMMON_REFLECTIONS */
