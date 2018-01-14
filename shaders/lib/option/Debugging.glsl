/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_OPTION_DEBUGGING
  #define INTERNAL_INCLUDED_OPTION_DEBUGGING

  //#define DEBUG_MODE

  //#define VISUALISE_PCSS_EDGE_PREDICTION

  //#define VISUALISE_HDR_SLICES // Halcyon natively uses a HDR pipeline, which allows for colours to exceed the 0.0 -> 1.0 range. Unfortunately, this means conveying colours outside this range isn't easy, since monitors only work in the 0.0 -> 1.0 range. This option divides the screen into a 5x5 grid, 25 total tiles, and gives each tile a custom exposure, showing different slices of the screen in LDR.

  //#define RENDER_DOF_WIDTH

#endif /* INTERNAL_INCLUDED_OPTION_DEBUGGING */
