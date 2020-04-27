#version 120

attribute vec3 position;
attribute vec2 texCoord;
attribute vec3 normal;

varying vec2 texCoord0;
varying vec3 normal0;
varying vec3 worldPos0;

uniform mat4 T_model;
uniform mat4 T_MVP;
uniform float useFakeLighting;

void main()
{
  gl_Position = T_MVP * vec4(position, 1.0);
  texCoord0 = texCoord;

  vec3 actualNormal = normal;
  if(useFakeLighting > 0.5) {
    // simulate lighting by setting normals to up
    actualNormal = vec3(0.0, 1.0, 0.0);
  }

  normal0 = (T_model * vec4(actualNormal, 0.0)).xyz;
  worldPos0 = (T_model * vec4(position, 1.0)).xyz;
}
