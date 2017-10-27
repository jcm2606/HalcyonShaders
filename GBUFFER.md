In Halcyon, the Gbuffer is a data structure containing information regarding the surface that a pixel belongs to. Examples of information stored inside the gbuffer are things like albedo, normal, material, object ID, lightmaps, etc.

# Albedo
A 3-component vector, where each channel holds the R, G and B values of a surface's base colour, respectively. Base colour refers to the innate colour of the surface, with no influence from lighting.

# Lightmap
A 2-component vector, the lightmap holds information on the intensity of block and ambient light for a given pixel, coming directly from Minecraft. Within the gbuffer, these values are untouched.

# Object ID
An integer between 0 and 255 representing the type of object a given pixel belongs to. This is used for numerous things, including masking pixels for subsurface effects, masking pixels for emission effects, and more.

# Normal
A 3-component vector that represents the direction a given pixel is pointing, relative to the observer.

# Material
A 4-component vector storing material information for the surface, such as roughness, reflectance, emission and porosity. These values together are central to properly shading surfaces in a realistic manner.
