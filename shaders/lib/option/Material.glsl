/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_OPTION_MATERIAL
  #define INTERNAL_INCLUDED_OPTION_MATERIAL

  #define RESOURCE_FORMAT 2 // Which format should the shader use for resource pack support?. Pick 'Harcoded' if you aren't using a resource pack that provides shader support. Pick 'Specular' if you are using a resource pack that uses a greyscale specular texture. Pick 'Old PBR, Emission' if you are using an old PBR resource pack that includes emission in the blue channel, 'Old PBR, No Emission' if it doesn't. Pick 'New PBR' if you are using a resource pack that uses the new Continuum / SEUS PBR standard, ie Pulchra. [0 1 2 3 4]

  /* smoothness, f0, emission, materialPlaceholder */

  #define MATERIAL_DEFAULT vec4(0.0, 0.02, 0.0, 0.0)
  
  #define MATERIAL_FOLIAGE vec4(0.32, 0.02, 0.0, 0.0)

  #define MATERIAL_WATER vec4(0.82, 0.05, 0.0, 0.0)
  #define MATERIAL_STAINED_GLASS vec4(0.93, 0.02, 0.0, 0.0)

#endif /* INTERNAL_INCLUDED_OPTION_MATERIAL */
