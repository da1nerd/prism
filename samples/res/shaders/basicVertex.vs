#version 320 es

layout (location = 0) in lowp vec3 position;

out lowp vec4 color;

uniform mediump mat4 transform;

void main()
{
  color = vec4(clamp(position, 0.0, 1.0), 1.0);
  gl_Position = transform * vec4(position, 1.0);
}
