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
varying vec3 worldPosition;

uniform mat4 transformation_matrix;
uniform mat4 projection_matrix;
uniform mat4 view_matrix;

void main(void) {
    worldPosition = (transformation_matrix * vec4(position, 1.0)).xyz;
    gl_Position = projection_matrix * view_matrix * vec4(worldPosition, 1.0);
    pass_textureCoords = textureCoords;
    surfaceNormal = (transformation_matrix * vec4(normal, 0.0)).xyz;
}
