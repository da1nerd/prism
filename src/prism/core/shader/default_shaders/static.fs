#version 120

varying vec2 pass_textureCoords;

uniform sampler2D diffuse;
uniform vec3 materialColor;

void main(void) {
    gl_FragColor = vec4(materialColor, 1.0) + texture2D(diffuse, pass_textureCoords);
}