#version 120
#include "lighting.glh"

struct Light
{
    vec3 color;
    vec3 position;
};

varying vec2 pass_textureCoords;
varying vec3 surfaceNormal;
varying vec3 worldPosition;
varying float visibility;

uniform sampler2D diffuse;
uniform vec3 materialColor;
uniform DirectionalLight light;
uniform vec3 sky_color;

void main(void) {
    vec4 textureColor = texture2D(diffuse, pass_textureCoords);
    // discards transparent pixels
    if (textureColor.a <= 0.5) {
        discard;
    }
    vec3 unitNormal = normalize(surfaceNormal);
    vec4 lightRays = calcDirectionalLight(light, unitNormal, worldPosition);
    lightRays = max(lightRays, 0.2);
    gl_FragColor = lightRays * (vec4(materialColor, 1.0) + textureColor);
    gl_FragColor = mix(vec4(sky_color, 1.0), gl_FragColor, visibility);
}