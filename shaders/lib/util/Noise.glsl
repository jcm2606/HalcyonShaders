/*
    Jcm2606.
    Halcyon.
    Please read "LICENSE.md" before editing this file.
*/

#if !defined INCLUDED_UTIL_NOISE
    #define INCLUDED_UTIL_NOISE

    #define noise2D(coord) texture2D(noisetex, fract(coord)).xy

    vec2 noise2DSmooth(vec2 coord) {
        const float resolution    = 64.0;
        const float resolutionRCP = rcp(resolution);

        coord *= resolution;
        coord += 0.5;

        vec2 whole = floor(coord);
        vec2 part  = fract(coord);

        part.x = part.x * part.x * (3.0 - 2.0 * part.x);
        part.y = part.y * part.y * (3.0 - 2.0 * part.y);

        coord = whole + part;

        coord -= 0.5;
        coord *= resolutionRCP;

        return texture2D(noisetex, fract(coord)).xy;
    }

    float noise3D(vec3 coord) {
        const float resolution    = 64.0;
        const float resolutionRCP = rcp(resolution);

        float p = floor(coord.z);
        float f = coord.z - p;

        vec2 xy = coord.xy * resolutionRCP;
        vec2 z  = vec2(p * 17.0 * resolutionRCP);

        vec2 noise = texture2D(noisetex, fract(xy + z)).xy;
        
        return mix(noise.x, noise.y, f);
    }

#endif
