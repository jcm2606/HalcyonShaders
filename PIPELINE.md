# Halcyon Pipeline
* deferred: AO generation.
* deferred1: Sky, back shading.
* deferred2: Back reflections.
* gbuffers_water: Surface-to-eye water absorption, front reflection sampling, front shading.
* composite: Volumetrics sampling, volumetric cloud sampling, surface-to-eye water absorption application, front reflection buffer swap.
* composite1: Combined volumetrics & cloud application, front reflection application.
* composite2: Camera exposure w/ temporally accumulated luma compensation.
* composite3: DOF with temporally accumulated center depth.
* composite4: Bloom tile sampling.
* final: Bloom application, tonemapping.
