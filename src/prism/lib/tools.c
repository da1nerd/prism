#include "tools.h"

#include <stdio.h>

#ifdef __APPLE__
#include <OpenGL/gl.h>
#include <OpenGL/glu.h>
#include <GLUT/glut.h>
#else
#ifdef _WIN32
  #include <windows.h>
#endif
#include <GL/gl.h>
#include <GL/glu.h>
#include <GL/glut.h>
#endif

#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"


// This is here so we can quickly mock out c commands as needed.
// Ideally this will only be needed for debugging how to use third party c libraries.

// TODO: eventually move image loading into Crystal
unsigned char *load_png(char const *filename, int *width, int *height, int *color_channels) {
  unsigned char *data = stbi_load(filename, width, height, color_channels, 0);
  return data;
}
