#version 120

attribute vec3 position;
attribute vec2 textureCoords;
attribute vec3 normal;

varying vec2 pass_textureCoords;

uniform mat4 transformation_matrix;
uniform mat4 projection_matrix;

void main(void) {
    gl_Position = projection_matrix * transformation_matrix * vec4(position, 1.0);
    pass_textureCoords = textureCoords;
}
