#version 140

struct Light
{
    vec3 color;
    vec3 position;
};

in vec3 position;
in vec2 textureCoords;
in vec3 normal;

out vec2 pass_textureCoords;
out vec3 surfaceNormal;
out vec3 toLightVector;
out vec3 toCameraVector;
out vec3 worldPosition;
out float visibility;

uniform mat4 transformation_matrix;
uniform mat4 projection_matrix;
uniform mat4 view_matrix;
uniform float useFakeLighting;
uniform Light lights[1];

// offset for texture atlas
uniform float numberOfRows;
uniform vec2 offset;

// fog const
const float density = 0.0035;
const float gradient = 5.0;

void main(void) {
    vec3 actualNormal = normal;
    if(useFakeLighting > 0.5) {
        // simulate lighting by setting normals to up
        actualNormal = vec3(0.0, 1.0, 0.0);
    }

    worldPosition = (transformation_matrix * vec4(position, 1.0)).xyz;
    vec4 positionRelativeToCam = view_matrix * vec4(worldPosition, 1.0);
    gl_Position = projection_matrix * positionRelativeToCam;

    pass_textureCoords = (textureCoords / numberOfRows) + offset;

    surfaceNormal = (transformation_matrix * vec4(actualNormal, 0.0)).xyz;
    toLightVector = lights[0].position - worldPosition.xyz;

    vec3 cameraPosition = (inverse(view_matrix) * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
    toCameraVector = cameraPosition - worldPosition.xyz;

    // distance of this vertex to the camera
    float distance = length(positionRelativeToCam.xyz);
    visibility = exp(-pow((distance*density), gradient));
    visibility = clamp(visibility, 0.0, 1.0);
}
