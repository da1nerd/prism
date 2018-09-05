cmake_minimum_required(VERSION 3.10)
project(tools C)

set(CMAKE_C_STANDARD 99)

add_library(tools tools.c tools.h)

find_package(OpenGL REQUIRED)
include_directories( ${OPENGL_INCLUDE_DIRS} )
target_link_libraries(tools ${OPENGL_LIBRARY} )
