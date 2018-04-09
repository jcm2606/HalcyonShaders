/*
    Jcm2606.
    Halcyon.
    Please read "LICENSE.md" before editing this file.
*/

// Constants.
// Varyings.
varying vec4 tint;

varying vec3 viewPosition;
varying vec3 worldPosition;

varying vec3 vertexNormal;

varying vec2 uvCoord;
varying vec2 lmCoord;

flat(mat3) tbn;
flat(mat2) tileInfo;

flat(vec2) entity;

flat(float) materialID;

// Screen Samples.
// Uniforms.
uniform sampler2D texture;
uniform sampler2D normals;
uniform sampler2D specular;

// Structs.
// Globals.
// Includes.
// Functions.
// Main.
void main() {
    float alphaSign = sign(tint.a);

    vec3 normal = vec3(0.5, 0.5, 1.0);
         normal = tbn * (normal * 0.5 + 0.5);

    /* DRAWBUFFERS:01 */
    gl_FragData[0] = vec4(EncodeAlbedo(tint.rgb), 0.0, Encode4x8F(vec4(lmCoord, 0.0, 0.0)), alphaSign);
    gl_FragData[1] = vec4(EncodeNormal(normal * 0.5 + 0.5), 0.0, Encode4x8F(vec4(materialID * materialIDMult, 0.0, 0.0, 0.0)), alphaSign);
}
// EOF.
