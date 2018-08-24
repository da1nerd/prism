#ifndef FREEGLUT_CLOSURE_LIBRARY_H
#define FREEGLUT_CLOSURE_LIBRARY_H

void glutDisplayFuncWithContext(void (*callback)(void *data), void *data);
void glutCloseFuncWithContext(void (*callback)(void *data), void *data);
void glutKeyboardFuncWithContext(void (*callback)(void *data, unsigned char, int, int), void *data);
void glutSpecialFuncWithContext(void (*callback)(void *data, int, int, int), void *data);
void glutMouseFuncWithContext(void (*callback)(void *data, int, int, int, int), void *data);
void glutMotionFuncWithContext(void (*callback)(void *data, int, int), void *data);
void glutPassiveMotionFuncWithContext(void (*callback)(void *data, int, int), void *data);

#endif
