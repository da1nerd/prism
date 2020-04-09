#version 120
#include "lighting.glh"

varying vec2 texCoord0;
varying vec3 normal0;
varying vec3 worldPos0;

uniform sampler2D diffuse;
uniform DirectionalLight R_directionalLight;
uniform vec3 materialColor;

void main()
{
  vec4 color = (vec4(materialColor, 1.0) + texture2D(diffuse, texCoord0.xy)) * calcDirectionalLight(R_directionalLight, normalize(normal0), worldPos0);
  // discards transparent pixels
  if (color.a <= 0.0) {
    discard;
  }
  gl_FragColor = color;
}
