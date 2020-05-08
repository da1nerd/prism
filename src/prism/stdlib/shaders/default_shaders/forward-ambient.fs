#version 120

varying vec2 texCoord0;

uniform vec3 R_ambient;
uniform sampler2D diffuse;
uniform vec3 materialColor;

void main()
{
  vec4 textureColor = texture2D(diffuse, texCoord0.xy);
  // discards transparent pixels
  if (textureColor.a <= 0.5) {
    discard;
  }
  vec4 color = (vec4(materialColor, 1.0) + textureColor) * vec4(R_ambient, 1);
  gl_FragColor = color;
}
