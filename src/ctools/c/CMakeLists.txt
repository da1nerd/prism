cmake_minimum_required(VERSION 3.10)
project(ctools C)

set(CMAKE_C_STANDARD 99)

add_library(ctools ctools.c ctools.h)

find_package(OpenGL REQUIRED)
include_directories( ${OPENGL_INCLUDE_DIRS} )
target_link_libraries(ctools ${OPENGL_LIBRARY} )
