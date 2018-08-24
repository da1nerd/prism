#include "freeglut_context.h"

#include <stdio.h>

#ifdef __APPLE__
#include <GLUT/freeglut.h>
#else
#include <GL/freeglut.h>
#endif

// callback context
void* display_func_context;
void* close_func_context;
void* keyboard_func_context;
void* special_func_context;
void* mouse_func_context;
void* motion_func_context;
void* passive_motion_func_context;

// callback function pointers
void (*display_func_ptr)(void*);
void (*close_func_ptr)(void*);
void (*keyboard_func_ptr)(void*, unsigned char, int, int );
void (*special_func_ptr)(void*, int, int, int );
void (*mouse_func_ptr)(void*, int, int, int, int);
void (*motion_func_ptr)(void*, int, int);
void (*passive_motion_func_ptr)(void*, int, int);

// callback wrappers
void _glutDisplayFuncHandler() {(*display_func_ptr)(display_func_context);}
void _glutCloseFuncHandler() {(*close_func_ptr)(close_func_context);}
void _glutKeyboardFuncHandler(unsigned char key, int x, int y) {
  (*keyboard_func_ptr)(keyboard_func_context, key, x, y);
}
void _glutSpecialFuncHandler(int key, int x, int y) {
  (*special_func_ptr)(special_func_context, key, x, y);
}
void _glutMouseFuncHandler(int button, int state, int x, int y) {
  (*mouse_func_ptr)(mouse_func_context, button, state, x, y);
}
void _glutMotionFuncHandler(int x, int y) {
  (*motion_func_ptr)(motion_func_context, x, y);
}
void _glutPassiveMotionFuncHandler(int x, int y) {
  (*passive_motion_func_ptr)(passive_motion_func_context, x, y);
}

// contextualized glut methods
void glutDisplayFuncWithContext(void (*callback)(void *data), void *data) {
    display_func_ptr = callback;
    display_func_context = data;
    glutDisplayFunc(_glutDisplayFuncHandler);
}
void glutCloseFuncWithContext(void (*callback)(void *data), void *data) {
    close_func_ptr = callback;
    close_func_context = data;
    glutCloseFunc(_glutCloseFuncHandler);
}
void glutKeyboardFuncWithContext(void (*callback)(void *data, unsigned char, int, int), void *data ) {
    keyboard_func_ptr = callback;
    keyboard_func_context = data;
    glutKeyboardFunc(_glutKeyboardFuncHandler);
}
void glutSpecialFuncWithContext(void (*callback)(void *data, int, int, int), void *data) {
  special_func_ptr = callback;
  special_func_context = data;
  glutSpecialFunc(_glutSpecialFuncHandler);
}
void glutMouseFuncWithContext( void (* callback)(void *data, int, int, int, int), void *data ) {
    mouse_func_ptr = callback;
    mouse_func_context = data;
    glutMouseFunc(_glutMouseFuncHandler);
}
void glutMotionFuncWithContext( void (* callback)(void* data, int, int), void *data ) {
    motion_func_ptr = callback;
    motion_func_context = data;
    glutMotionFunc(_glutMotionFuncHandler);
}
void glutPassiveMotionFuncWithContext( void (* callback)(void *data, int, int), void *data ) {
    passive_motion_func_ptr = callback;
    passive_motion_func_context = data;
    glutPassiveMotionFunc(_glutPassiveMotionFuncHandler);
}
