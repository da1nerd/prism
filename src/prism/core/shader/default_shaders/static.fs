#version 120

struct Light
{
    vec3 color;
    vec3 position;
};

varying vec2 pass_textureCoords;
varying vec3 surfaceNormal;
varying vec3 toLightVector;
varying vec3 toCameraVector;

uniform sampler2D diffuse;
uniform vec3 materialColor;
uniform Light light;
uniform float specularPower;
uniform float specularIntensity;

void main(void) {
    vec3 unitNormal = normalize(surfaceNormal);
    vec3 unitLightVector = normalize(toLightVector);

    float nDot1 = dot(unitNormal, unitLightVector);
    float brightness = max(nDot1, 0.2); // TODO: pass the 0.2 in as an ambient light.
    vec3 stuff = brightness * light.color;

    vec3 unitVectorToCamera = normalize(toCameraVector);
    vec3 lightDirection = -unitLightVector;
    vec3 reflectedLightDirection = reflect(lightDirection, unitNormal);
    float specularFactor = dot(reflectedLightDirection, unitVectorToCamera);
    specularFactor = max(specularFactor, 0.0);
    float dampedFactor = pow(specularFactor, specularPower);
    vec3 finalSpecular = dampedFactor * light.color * specularIntensity;

    gl_FragColor = vec4(stuff, 1.0) * (vec4(materialColor, 1.0) + texture2D(diffuse, pass_textureCoords)) + vec4(finalSpecular, 1.0);
}