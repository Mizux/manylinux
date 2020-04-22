# This file is just an orchestration
cmake_minimum_required(VERSION 3.14)

project(Manylinux VERSION 1.0 LANGUAGES CXX)
message(STATUS "project: ${PROJECT_NAME}")
message(STATUS "version: ${PROJECT_VERSION}")

# Find Python
# see: https://cmake.org/cmake/help/latest/module/FindPython.html
#find_package(Python REQUIRED COMPONENTS Interpreter)
find_package(Python REQUIRED COMPONENTS Interpreter Development)

message(STATUS "Executable: ${Python_EXECUTABLE}")
message(STATUS "Include Dirs: ${Python_INCLUDE_DIRS}")
message(STATUS "Libraries: ${Python_LIBRARIES}")

