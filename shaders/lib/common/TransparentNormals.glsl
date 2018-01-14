/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_COMMON_TRANSPARENTNORMALS
  #define INTERNAL_INCLUDED_COMMON_TRANSPARENTNORMALS
  
  #include "/lib/common/util/Noise.glsl"

  // WATER
  float water0(in vec3 world) {
    float height = 1.0;

    vec2 position = world.xz - world.y;
    cv(mat2) rot = rot2(-0.7);

    position *= rot;
    position *= 0.0011;
    position.x *= 0.65;

    float weight = 1.0;
    float totalWeight = 0.0;

    cv(vec2) windDir = vec2(0.0, 1.0);
    vec2 wind = windDir * frametime;
    float windSpeed = 0.004;

    for(int i = 0; i < 5; i++) {
      totalWeight += weight;

      height -= texnoise2D(noisetex, wind * windSpeed + position) * weight;

      position *= 2.0;
      //position.x *= 1.07;
      //position *= rot;
      //wind *= rot;
      windSpeed *= 1.6;
      weight *= 0.45;
    }

    return height / totalWeight * 0.95;
  }

  float water1(in vec3 world) {
    float height = 1.0;

    vec2 position = world.xz - world.y;
    cv(mat2) rot = rot2(-0.7);

    position *= rot;
    position *= 0.0013;
    //position.x *= 0.35;

    float weight = 1.0;
    float totalWeight = 0.0;

    cv(vec2) windDir = vec2(0.0, 1.0);
    vec2 wind = windDir * frametime;
    float windSpeed = 0.004;

    for(int i = 0; i < 4; i++) {
      totalWeight += weight;

      height -= texnoise2D(noisetex, wind * windSpeed + position) * weight;

      position *= 2.2;
      //position.x *= 1.07;
      position *= rot;
      //wind *= rot;
      windSpeed *= 1.6;
      weight *= 0.4;
    }

    return height / totalWeight * 0.6;
  }

  float water2(in vec3 world) {
    float height = 1.0;

    vec2 position = world.xz - world.y;
    cv(mat2) rot = rot2(-0.7);

    position *= rot;
    position *= 0.013;
    position.x *= 0.65;

    float weight = 1.0;
    float totalWeight = 0.0;

    cv(vec2) windDir = vec2(0.0, 1.0);
    vec2 wind = windDir * frametime;
    float windSpeed = 0.01;

    for(int i = 0; i < 6; i++) {
      totalWeight += weight;

      height -= texnoise2D(noisetex, wind * windSpeed + position) * weight;

      //position *= 1.3;
      //position.x *= 1.07;
      position *= rot;
      //wind *= rot;
      windSpeed *= 1.3;
      weight *= 0.5;
    }

    return height / totalWeight * 0.2;
  }

  float getWaterHeight(in vec3 world) {
    return _WaterHeight(world);
  }

  // ICE
  float getIceHeight(in vec3 world) {
    return 0.0;
  }

  // STAINED GLASS
  float glass0(in vec3 world) {
    float height = 0.0;

    cv(mat2) rot = rot2(-0.6);

    vec2 position = world.xz - world.y;

    position *= 0.005;
    position *= vec2(2.0, 0.5);

    position *= rot; height += texnoise2D(noisetex, position);
    position *= rot; height += texnoise2D(noisetex, position * 2.0) * 0.5;
    position *= rot; height += texnoise2D(noisetex, position * 4.0) * 0.25;

    return height * 0.05;
  }

  float getGlassHeight(in vec3 world) {
    return glass0(world);
  }
  
  // GENERIC
  float getHeight(in vec3 world, in float objectID) {
    float height = 0.0;

    if(comparef(objectID, OBJECT_WATER, ubyteMaxRCP)) height = getWaterHeight(world);
    if(comparef(objectID, OBJECT_ICE, ubyteMaxRCP)) height = getIceHeight(world);
    if(comparef(objectID, OBJECT_STAINED_GLASS, ubyteMaxRCP)) height = getGlassHeight(world);

    return height;
  }

  vec3 getNormal(in vec3 world, in float objectID) {
    cv(float) normalDelta = 0.4;
    cRCP(float, normalDelta);

    float height0 = getHeight(world, objectID);
    float height1 = getHeight(world + vec3( normalDelta, 0.0, 0.0), objectID);
    float height2 = getHeight(world + vec3(-normalDelta, 0.0, 0.0), objectID);
    float height3 = getHeight(world + vec3(0.0, 0.0,  normalDelta), objectID);
    float height4 = getHeight(world + vec3(0.0, 0.0, -normalDelta), objectID);

    vec2 delta = vec2(
      ((height1 - height0) + (height0 - height2)),
      ((height3 - height0) + (height0 - height4))
    ) * normalDeltaRCP;

    return normalize(vec3(delta.x, delta.y, 1.0 - pow2(delta.x) - pow2(delta.y)));
  }

#endif /* INTERNAL_INCLUDED_COMMON_TRANSPARENTNORMALS */
