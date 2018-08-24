#include "library.h"

#include <stdio.h>

#ifdef __APPLE__
#include <GLUT/freeglut.h>
#else
#include <GL/freeglut.h>
#endif

void* display_func_context;
void (*display_func_ptr)(void*);

void* close_func_context;
void (*close_func_ptr)(void*);

/**
 * Internal handlers to send context back to the callbacks
 */
void _glutDisplayFuncHandler() {
    (*display_func_ptr)(display_func_context);
}
void _glutCloseFuncHandler() {
    (*close_func_ptr)(close_func_context);
}

/**
 * glutDisplayFunc with context support.
 * @param callback
 * @param data
 */
void glutDisplayFuncWithContext(void (*callback)(void *data), void *data) {
    display_func_ptr = callback;
    display_func_context = data;
    glutDisplayFunc(_glutDisplayFuncHandler);
}

/**
 * glutCloseFunc with context support.
 * @param callback
 * @param data
 */
void glutCloseFuncWithContext(void (*callback)(void *data), void *data) {
    close_func_ptr = callback;
    close_func_context = data;
    glutCloseFunc(_glutCloseFuncHandler);
}