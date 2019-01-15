
# CMakeshift script library
# Author: Moritz Beutel


## 1. Prologue and public interface
## ================================

cmake_minimum_required(VERSION 3.11)

# Disable in-source builds to avoid cluttering the source directory.
# If you attempted to build in the source directory and run into this error, you first need to clean up
# manually by deleting the CMakeFiles directory and the CMakeCache.txt file before proceeding.
set(CMAKE_DISABLE_SOURCE_CHANGES ON)
set(CMAKE_DISABLE_IN_SOURCE_BUILD ON)

# Define the project.
project(CMakeshift
    VERSION 3.1.0
    LANGUAGES)


## 2. Targets
## ==========

# Define project targets.
add_subdirectory(src)


## 3. Installation
## ===============

include(include/CMakeshift/InstallSimpleLibraryPackage.cmake)
cmakeshift_install_simple_library_package(
    INTERFACE
    VERSION_COMPATIBILITY SameMajorVersion
    CONFIG_TEMPLATE "${PROJECT_SOURCE_DIR}/cmake/${PROJECT_NAME}Config.cmake.in")
