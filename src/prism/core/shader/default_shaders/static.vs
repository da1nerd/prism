#version 120

attribute vec3 position;
attribute vec2 textureCoords;
attribute vec3 normal;

varying vec2 pass_textureCoords;

uniform mat4 T_MVP;

void main(void) {
    gl_Position = T_MVP * vec4(position, 1.0);
    pass_textureCoords = textureCoords;
}
