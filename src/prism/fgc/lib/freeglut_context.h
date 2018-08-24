#ifndef FREEGLUT_CLOSURE_LIBRARY_H
#define FREEGLUT_CLOSURE_LIBRARY_H

void glutDisplayFuncWithContext(void (*callback)(void *data), void *data);
void _glutDisplayFuncHandler();

void glutCloseFuncWithContext(void (*callback)(void *data), void *data);
void _glutCloseFuncHandler();

#endif