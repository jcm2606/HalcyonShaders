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

    c(float) radius = 0.01 * SUN_SIZE;
    float d = cos(radius);

    float LdotR = dot(light, reflected);

    return (LdotR < d) ? normalize(d * light + (normalize(reflected - LdotR * light) * sin(radius))) : reflected;
  }

  vec4 getReflections(in int layer, in sampler2D tex, in vec3 view, in mat2x3 atmosphereLighting, in vec3 albedo, in vec3 normal, in float roughness, in float f0, in vec4 highlightTint, in float skyOcclusion) {
    // CREATE DATA
    vec3 dir = -normalize(view);
    vec2 alpha = pow2(vec2(roughness * 2.45, roughness * 1.6));
    float metallic = (f0 > 0.5) ? 1.0 : 0.0;

    // CREATE REFLECTION VECTORS
    vec3 reflView = reflect(normalize(view), normalize(normal));

    // RAYTRACE
    vec4 specular = raytraceClip(tex, -reflect(dir, normalize(normal)), view);

    // SAMPLE SKY IN REFLECTED DIRECTION
    vec3 sky = drawSky(reflView, 2) * pow4(skyOcclusion) * 1.5;

    // ADD-IN POINT: Volumetric cloud reflection.

    // BLEND BETWEEN RAYTRACED AND SKY SAMPLES
    specular.rgb = mix(sky, specular.rgb, specular.a);

    // APPLY FRESNEL
    float fresnel = ((1.0 - f0) * pow5(1.0 - max0(dot(dir, normalize(reflView + dir)))) + f0) * max0(1.0 - alpha.x);
    specular.rgb *= (layer == 0) ? fresnel : 1.0;

    // APPLY SPECULAR HIGHLIGHT
    vec3 light = sunMRP(normalize(normal), normalize(view), lightVector);
    float highlight = ggx(normalize(view), normalize(normal), light, alpha.y, f0);

    specular.rgb += min(vec3(SUN_BRIGHTNESS), atmosphereLighting[0] * highlight * highlightTint.rgb * highlightTint.a);

    // APPLY METALLIC TINTING
    specular.rgb *= (metallic > 0.5) ? albedo : vec3(1.0);

    return vec4(specular.rgb, fresnel);
  }

  vec3 drawReflectionOnSurface(in vec4 diffuse, in sampler2D tex, in vec3 view, in mat2x3 atmosphereLighting, in vec3 albedo, in vec3 normal, in float roughness, in float f0, in vec4 highlightTint, in float skyOcclusion) {
    return diffuse.rgb * ((f0 > 0.5) ? 0.0 : 1.0) + getReflections(0, tex, view, atmosphereLighting, albedo, normal, roughness, f0, highlightTint, skyOcclusion).rgb;
  }

#endif /* INTERNAL_INCLUDED_COMMON_REFLECTIONS */
