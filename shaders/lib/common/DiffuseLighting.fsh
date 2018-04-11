/*
    Jcm2606.
    Halcyon.
    Please read "LICENSE.md" before editing this file.
*/

#if !defined INCLUDED_COMMON_DIFFUSELIGHTING
    #define INCLUDED_COMMON_DIFFUSELIGHTING

    #include "/lib/common/Shadows.fsh"
    
    float CalculateBlockLightFalloff(const float blockLight) {
        float squareDistance = pow2(clamp((1.0 - blockLight) * 16.0, 0.0, 16.0));

        return (10.0 / max(squareDistance, pow2(0.01))) * (blockLight);
    }

    vec3 CalculateShadedFragment(const mat2x3 atmosphereLighting, const vec3 albedo, const vec3 normal, const vec3 shadowColour, const vec3 viewPosition, const vec2 screenCoord, const vec2 dither, const float blockLight, const float skyLight, const float parallaxShadow, const float vanillaAO, const float roughness, const float emission, const bool isSubsurfaceMaterial, const bool isEmissiveSurface) {
        vec3 directOcclusion = shadowColour * parallaxShadow;//mix(parallaxShadow, 1.0, saturate(pow4(fLength(viewPosition) * 0.05)));

        vec3 lightDirect  = atmosphereLighting[0];
             lightDirect *= directOcclusion;
             lightDirect *= max0(dot(lightDirection, normal));
             lightDirect *= float(!isSubsurfaceMaterial) * 0.5 + 0.5;

        vec3 lightSky  = atmosphereLighting[1];
             lightSky *= pow(skyLight, 5.0);
             lightSky *= vanillaAO;
             lightSky *= max0(dot(upDirection, normal)) * 0.5 + 0.5;

        CFUNC_Blackbody(3700, lightBlockColour)

        vec3 lightBlock  = lightBlockColour;
             lightBlock *= CalculateBlockLightFalloff(blockLight);
             
        if(isEmissiveSurface || emission > 0.1)
             lightBlock  = lightBlockColour * emission;

        vec3 sss  = atmosphereLighting[0];
             sss *= shadowColour;
             sss *= 0.5;
             sss *= albedo;
             sss *= float(isSubsurfaceMaterial);
        
        return albedo * (lightDirect + lightSky + lightBlock + sss);
    }

    vec3 CalculateShadedFragment(const MaterialObject materialObject, const SurfaceObject surfaceObject, const mat2x3 atmosphereLighting, const vec3 albedo, const vec3 viewPosition, const vec2 screenCoord, const vec2 dither) {
        return CalculateShadedFragment(atmosphereLighting, albedo, surfaceObject.normal, CalculateShadows(viewPosition, dither), viewPosition, screenCoord, dither, surfaceObject.blockLightShaded, surfaceObject.skyLightShaded, surfaceObject.parallaxShadow, surfaceObject.vanillaAO, surfaceObject.roughness, surfaceObject.emission, materialObject.subsurface, materialObject.emissive);
    }

#endif
