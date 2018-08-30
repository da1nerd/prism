#include "ctools.h"

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

// follow directions at https://www.khronos.org/opengl/wiki/VBO_-_just_examples
float data = {
  -1.0, -1.0, 0.0,
  -1.0, 1.0, 0.0,
  0.0, 1.0, 0.0
};

void* vbo;

void initialize() {
  // init
  glGenBuffers(1, vbo);

  // add verticies
  glBindBuffer(GL_ARRAY_BUFFER, vbo);
  glBufferData(GL_ARRAY_BUFFER, 3*4*3, &data[0], GL_STATIC_DRAW);
}

void getMesh() {
  // TODO: render mesh
}
