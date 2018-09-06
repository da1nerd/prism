#version 320 es

layout (location = 0) in lowp vec3 position;

out lowp vec4 color;

uniform lowp float uniformFloat;

void main()
{
  color = vec4(clamp(position, 0.0, uniformFloat), 1.0);
  gl_Position = vec4(position, 1.0);
}
