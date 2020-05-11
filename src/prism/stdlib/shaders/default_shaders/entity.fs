#version 140

struct Light
{
    vec3 color;
    vec3 position;
};

in vec2 pass_textureCoords;
in vec3 surfaceNormal;
in vec3 toLightVector;
in vec3 toCameraVector;
in vec3 worldPosition;
in float visibility;

out vec4 out_Color;

uniform sampler2D diffuse;
uniform vec3 materialColor;
uniform float shineDamper;
uniform float reflectivity;
uniform Light lights[1];
uniform vec3 sky_color;

void main(void) {
    vec4 textureColor = texture2D(diffuse, pass_textureCoords);
    // discards transparent pixels
    if (textureColor.a <= 0.5) {
        discard;
    }
    vec3 unitNormal = normalize(surfaceNormal);
    vec3 unitLightVector = normalize(toLightVector);

    float nDot1 = dot(unitNormal, unitLightVector);
    float brightness = max(nDot1, 0.2);
    vec3 diffuse = brightness * lights[0].color;

    vec3 unitVectorToCamera = normalize(toCameraVector);
    vec3 lightDirection = -unitLightVector;
    vec3 reflectedLightDirection = reflect(lightDirection, unitNormal);

    float specularFactor = dot(reflectedLightDirection, unitVectorToCamera);
    specularFactor = max(specularFactor, 0);
    float dampedFactor = pow(specularFactor, shineDamper);
    vec3 finalSpecular = dampedFactor * reflectivity * lights[0].color;

    // vec4 lightRays = calcDirectionalLight(light, unitNormal, worldPosition);
    // vec4 lightRays = vec4(0.0);
    // for(int i=0; i <1; i ++) {
    //     lightRays = lightRays + calcDirectionalLight(lights[i], unitNormal, worldPosition);
    // }

    // lightRays = max(lightRays, 0.2);
    out_Color = vec4(diffuse, 1.0) * (vec4(materialColor, 1.0) + textureColor) + vec4(finalSpecular, 1);
    out_Color = mix(vec4(sky_color, 1.0), out_Color, visibility);
}