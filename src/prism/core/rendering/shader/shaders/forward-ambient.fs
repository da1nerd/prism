#version 120

varying vec2 texCoord0;

uniform vec3 R_ambient;
uniform sampler2D diffuse;

void main()
{
  vec4 color = texture2D(diffuse, texCoord0.xy) * vec4(R_ambient, 1);
  // discards transparent pixels
  if (color.a <= 0.0) {
    discard;
  }
  gl_FragColor = color;
}
