#version 120

struct Light
{
    vec3 color;
    vec3 position;
};

varying vec2 pass_textureCoords;
varying vec3 surfaceNormal;
varying vec3 toLightVector;

uniform sampler2D diffuse;
uniform vec3 materialColor;
uniform Light light;

void main(void) {
    vec3 unitNormal = normalize(surfaceNormal);
    vec3 unitLightVector = normalize(toLightVector);

    float nDot1 = dot(unitNormal, unitLightVector);
    float brightness = max(nDot1, 0.0);
    vec3 stuff = brightness * light.color;

    gl_FragColor = vec4(stuff, 1.0) * (vec4(materialColor, 1.0) + texture2D(diffuse, pass_textureCoords));
}