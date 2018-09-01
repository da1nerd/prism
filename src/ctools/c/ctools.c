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


// GLuint vbo;
// GLuint size = 3; // number of verticies

void initMesh() {
  // init
  // glGenBuffers(1, vbo);

  // add verticies
  // glBindBuffer(GL_ARRAY_BUFFER, vbo);
  // glBufferData(GL_ARRAY_BUFFER, 3*3*sizeof(GLfloat), data, GL_STATIC_DRAW);
}

void getMesh() {
  // glGenBuffers(1, vbo);
  //
  // // add verticies
  // glBindBuffer(GL_ARRAY_BUFFER, vbo);
  // glBufferData(GL_ARRAY_BUFFER, 3*3*sizeof(GLfloat), data, GL_STATIC_DRAW);
  //
  // glEnableVertexAttribArray(0);
  //
  // glBindBuffer(GL_ARRAY_BUFFER, vbo);
  // glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * 4, 0);
  // glDrawArrays(GL_TRIANGLES, 0, size);
  //
  // glDisableVertexAttribArray(0);
  // draw_vbo();
  draw_triangle();
}

void draw_triangle() {
  GLfloat data[3][3] = {
    {-1.0, -1.0, 0.0},
    {0.0, 1.0, 0.0},
    {1.0, -1.0, 0.0}
  };

  GLuint vbo;
  glGenBuffers(1, &vbo);
  glBindBuffer(GL_ARRAY_BUFFER, vbo);
  glBufferData(GL_ARRAY_BUFFER, 9*sizeof(GLfloat), data, GL_STATIC_DRAW);

  glEnableVertexAttribArray(0);

  glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, 0);

  glDrawArrays(GL_TRIANGLES, 0, 9);

  glDisableVertexAttribArray(0);
}

void draw_vbo()
{
    GLuint vbo,ibo;
    GLfloat verts[8][3] = {{0.0, 0.0, 0.0},
			   {0.0, 0.0, 0.1},
			   {0.0, 0.1, 0.0},
			   {0.0, 0.1, 0.1},
			   {0.1, 0.0, 0.0},
			   {0.1, 0.0, 0.1},
			   {0.1, 0.1, 0.0},
			   {0.1, 0.1, 0.1}};
    GLubyte ind[8] = {0,3,6,9,12,15,18,21};

    glGenBuffers(1, &vbo);
    glGenBuffers(1, &ibo);

    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);

    glBufferData(GL_ARRAY_BUFFER, 24*sizeof(GLfloat), verts, GL_STATIC_DRAW);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, 8*sizeof(GLubyte), ind,
		 GL_STATIC_DRAW);

    glEnableClientState(GL_VERTEX_ARRAY);
    glVertexPointer(3, GL_FLOAT, sizeof(GLfloat), 0);
    glDrawElements(GL_LINE_STRIP, 8, GL_UNSIGNED_BYTE, 0);
    glDisableClientState(GL_VERTEX_ARRAY);

    glDeleteBuffers(1, &vbo);
    glDeleteBuffers(1, &ibo);
}
