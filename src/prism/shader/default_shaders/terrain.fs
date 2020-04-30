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

uniform sampler2D backgroundTexture;
uniform sampler2D rTexture;
uniform sampler2D gTexture;
uniform sampler2D bTexture;
uniform sampler2D blendMap;

uniform DirectionalLight light;
uniform vec3 sky_color;

void main(void) {
    vec4 blendMapColor = texture2D(blendMap, pass_textureCoords);

    float backTextureAmount = 1 - (blendMapColor.r + blendMapColor.g + blendMapColor.b);
    vec2 tiledCoords = pass_textureCoords * 40.0;
    vec4 backgroundTextureColor = texture2D(backgroundTexture, tiledCoords) * backTextureAmount;
    vec4 rTextureColor = texture2D(rTexture, tiledCoords) * blendMapColor.r;
    vec4 gTextureColor = texture2D(gTexture, tiledCoords) * blendMapColor.g;
    vec4 bTextureColor = texture2D(bTexture, tiledCoords) * blendMapColor.b;

    vec4 totalColor = backgroundTextureColor + rTextureColor + gTextureColor + bTextureColor;

    vec3 unitNormal = normalize(surfaceNormal);
    // vec3 unitLightVector = normalize(to_light_vector);

    // float nDot

    vec4 lightRays = calcDirectionalLight(light, unitNormal, worldPosition);
    lightRays = max(lightRays, 0.2);
    gl_FragColor = lightRays * totalColor;
    gl_FragColor = mix(vec4(sky_color, 1.0), gl_FragColor, visibility);
}