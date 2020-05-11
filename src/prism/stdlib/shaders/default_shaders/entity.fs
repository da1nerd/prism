#version 140

struct Light
{
    vec3 color;
    vec3 position;
};

const int maxLights = 1;

in vec2 pass_textureCoords;
in vec3 surfaceNormal;
in vec3 toLightVector[1];
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
    vec3 unitVectorToCamera = normalize(toCameraVector);
    vec3 unitNormal = normalize(surfaceNormal);

    vec3 totalDiffuse = vec3(0.0);
    vec3 totalSpecular = vec3(0.0);

    for(int i=0; i <1; i ++) {
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

    vec4 textureColor = texture2D(diffuse, pass_textureCoords);
    // discards transparent pixels
    if (textureColor.a <= 0.5) {
        discard;
    }

    out_Color = vec4(totalDiffuse, 1.0) * (vec4(materialColor, 1.0) + textureColor) + vec4(totalSpecular, 1);
    out_Color = mix(vec4(sky_color, 1.0), out_Color, visibility);
}