#version 140

struct Light
{
    vec3 color;
    vec3 position;
};

const int maxLights = 4;

in vec2 pass_textureCoords;
in vec3 surfaceNormal;
in vec3 toLightVector[4];
in vec3 toCameraVector;
in vec3 worldPosition;
in float visibility;

out vec4 out_Color;

uniform sampler2D backgroundTexture;
uniform sampler2D rTexture;
uniform sampler2D gTexture;
uniform sampler2D bTexture;
uniform sampler2D blendMap;

uniform float shineDamper;
uniform float reflectivity;
uniform Light lights[4];
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

    vec3 unitVectorToCamera = normalize(toCameraVector);
    vec3 unitNormal = normalize(surfaceNormal);

    vec3 totalDiffuse = vec3(0.0);
    vec3 totalSpecular = vec3(0.0);

    for(int i=0; i < maxLights; i ++) {
        vec3 unitLightVector = normalize(toLightVector[i]);
        float nDot1 = dot(unitNormal, unitLightVector);
        float brightness = max(nDot1, 0.0);
        vec3 lightDirection = -unitLightVector;
        vec3 reflectedLightDirection = reflect(lightDirection, unitNormal);
        float specularFactor = dot(reflectedLightDirection, unitVectorToCamera);
        specularFactor = max(specularFactor, 0);
        float dampedFactor = pow(specularFactor, shineDamper);
        totalDiffuse = totalDiffuse + brightness * lights[i].color;
        totalSpecular = totalSpecular + dampedFactor * reflectivity * lights[i].color;
    }
    totalDiffuse = max(totalDiffuse, 0.2);

    // vec4 lightRays = calcDirectionalLight(light, unitNormal, worldPosition);
    // lightRays = max(lightRays, 0.2);
    out_Color = vec4(totalDiffuse, 1) * totalColor + vec4(totalSpecular, 1);
    out_Color = mix(vec4(sky_color, 1.0), out_Color, visibility);
}