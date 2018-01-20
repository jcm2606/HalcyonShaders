/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#ifndef INTERNAL_INCLUDED_COMMON_NORMALS
  #define INTERNAL_INCLUDED_COMMON_NORMALS

  #if PROGRAM == GBUFFERS_WATER || PROGRAM == SHADOW
    #include "/lib/util/Noise.glsl"

    // WATER HEIGHT
    float gerstner(in vec2 coord, in float time, in float waveSteepness, in float waveAmplitude, in float waveLength, in vec2 waveDirection) {
      cv(float) g = 19.6;

      float k = tau / waveLength;
      float w = sqrt(g * k);

      float x = w * time - k * dot(waveDirection, coord);
      float wave = sin(x) * 0.5 + 0.5;

      return waveAmplitude * _pow(wave, waveSteepness);
    }

    float water0(in vec3 world) {
      float height = 0.0;

      vec2 position = world.xz - world.y;
      vec2 noisePosition = position * 0.005;

      cv(int) octaves = 14;

      float move = 0.3 * globalTime;

      float waveSteepness = 0.85;
      float waveAmplitude = 0.5;
      vec2 waveDirection = vec2(0.5, 0.2);
      float waveLength = 8.0;
      float rotation = 0.0;

      for(int i = 0; i < octaves; i++) {
        float noise = texnoise2D(noisetex, noisePosition / sqrt(waveLength));

        height += -gerstner(position + noise * sqrt(waveLength), move, waveSteepness, waveAmplitude, waveLength, waveDirection) - noise * waveAmplitude;

        waveSteepness *= 1.025;
        waveAmplitude *= 0.645;
        waveLength *= 0.725;
        waveDirection = rotate(waveDirection, rotation);
        move *= 1.07;
        rotation += pi + 0.33333;
      }

      return height;
    }

    // GENERIC HEIGHT
    float getHeight(in vec3 world, in float objectID) {
      float height = 0.0;

      if(compare(objectID, OBJECT_WATER)) height = _waterHeight(world);

      return height;
    }

    // GENERIC NORMAL
    vec3 getNormal(in vec3 world, in float objectID) {
      cv(float) deltaDist = 0.4;
      cv(vec2) deltaPos = vec2(deltaDist, 0.0);

      float height0 = getHeight(world, objectID);
      float height1 = getHeight(world + deltaPos.xyy, objectID);
      float height2 = getHeight(world + deltaPos.yyx, objectID);

      vec2 delta = vec2(height0 - height1, height0 - height2);

      return normalize(vec3(
        delta.x,
        delta.y,
        1.0 - _sqr(delta.x) - _sqr(delta.y)
      ));
    }
  #endif

#endif /* INTERNAL_INCLUDED_COMMON_NORMALS */
