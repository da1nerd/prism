#version 120

struct Light
{
    vec3 color;
    vec3 position;
};

attribute vec3 position;
attribute vec2 textureCoords;
attribute vec3 normal;

varying vec2 pass_textureCoords;
varying vec3 surfaceNormal;
varying vec3 toLightVector;

uniform mat4 transformation_matrix;
uniform mat4 projection_matrix;
uniform mat4 view_matrix;
uniform Light light;

void main(void) {
    vec4 worldPosition = transformation_matrix * vec4(position, 1.0);
    gl_Position = projection_matrix * view_matrix * worldPosition;
    pass_textureCoords = textureCoords;

    surfaceNormal = (transformation_matrix * vec4(normal, 0.0)).xyz;
    toLightVector = light.position - worldPosition.xyz;
}
