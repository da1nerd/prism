#version 120
#include "lighting.glh"

varying vec2 texCoord0;
varying vec3 normal0;
varying vec3 worldPos0;

uniform sampler2D diffuse;
uniform SpotLight R_spotLight;
uniform vec3 materialColor;

void main()
{
  vec4 textureColor = texture2D(diffuse, texCoord0.xy);
  // discards transparent pixels
  if (textureColor.a <= 0.5) {
    discard;
  }
  vec4 color = (vec4(materialColor, 1.0) + textureColor) * calcSpotLight(R_spotLight, normalize(normal0), worldPos0);
  gl_FragColor = color;
}
