cmake_minimum_required(VERSION 3.10)
project(freeglut_context C)

set(CMAKE_C_STANDARD 99)

add_library(freeglut_context library.c library.h)

find_package(GLUT REQUIRED)
include_directories( ${GLUT_INCLUDE_DIRS} )
target_link_libraries(freeglut_context ${GLUT_LIBRARY} )
