/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#ifndef INTERNAL_INCLUDED_COMMON_NORMALS
  #define INTERNAL_INCLUDED_COMMON_NORMALS

  #if PROGRAM == GBUFFERS_WATER || PROGRAM == SHADOW || PROGRAM == DEFERRED0 || PROGRAM == COMPOSITE0
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

      cv(int) octaves = WATER_WAVE_0_OCTAVES;

      float move = 0.3 * globalTime;

      float waveSteepness = 0.55;
      float waveAmplitude = 0.6;
      vec2 waveDirection = vec2(0.5, 0.2);
      float waveLength = 8.0;
      float rotation = 0.0;

      vec2 noise = vec2(0.0);

      for(int i = 0; i < octaves; i++) {
        noise = texnoise2D(noisetex, noisePosition / sqrt(waveLength));

        height += -gerstner(position + (noise * 2.0 - 1.0) * sqrt(waveLength) * 2.0, move, waveSteepness, waveAmplitude, waveLength, waveDirection) - noise.x * waveAmplitude;

        waveSteepness *= 1.125;
        waveAmplitude *= 0.635;
        waveLength *= 0.725;
        waveDirection = rotate(waveDirection, rotation);
        move *= 1.05;
        rotation += tau + 0.33333;
      }

      return height;
    }

    float water1(in vec3 world) {
      float height = 1.0;

      vec2 position = world.xz - world.y;

      cv(mat2) rot = rotate2(-0.7);

      position *= rot;
      position *= 0.0011;
      position.y *= 0.65;

      float weight = 1.0;
      float totalWeight = 0.0;

      cv(vec2) wind = 0.01 * swizzle2;
      vec2 move = wind * globalTime;

      for(int i = 0; i < 6; i++) {
        totalWeight += weight;

        height -= texnoise2DSmooth(noisetex, position + move) * weight;

        position *= 2.0;
        //position *= rot;
        move *= 1.6;
        weight *= 0.45;
      }

      return height / totalWeight * 2.0;
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

      vec3 normal = _normalize(vec3(delta.x, delta.y, 1.0 - _sqr(delta.x) - _sqr(delta.y)));

      cv(float) normalAnisotropy = 0.3;
      normal = normal * vec3(normalAnisotropy) + vec3(0.0, 0.0, 1.0 - normalAnisotropy);

      return normal;
    }
  #endif

#endif /* INTERNAL_INCLUDED_COMMON_NORMALS */
