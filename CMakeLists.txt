
# CMakeshift script library
# Author: Moritz Beutel


cmake_minimum_required(VERSION 3.14)

# Project definition
project(CMakeshift
    VERSION 4.0.0
    LANGUAGES)

# Build options
option(CMAKESHIFT_BUILD_DOCUMENTATION "Build documentation" OFF)

# Targets
if(CMAKESHIFT_BUILD_DOCUMENTATION)
    add_subdirectory(doc)
endif()

list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")
find_package(CMakeshift ${CMakeshift_VERSION} MODULE EXACT REQUIRED)

# Installation
include(GNUInstallDirs) # for CMAKE_INSTALL_DATADIR
message("CMAKE_MODULE_PATH: ${CMAKE_MODULE_PATH}")
include(CMakeshift/InstallBasicPackageFiles)
set(CMakeshift_BUILD_DATADIR "${PROJECT_SOURCE_DIR}/cmake")
set(CMakeshift_INSTALL_DATADIR "${CMAKE_INSTALL_DATADIR}/CMakeshift/cmake")
install(
    DIRECTORY "${CMakeshift_BUILD_DATADIR}/" # the trailing '/' is significant
    DESTINATION ${CMakeshift_INSTALL_DATADIR})
cmakeshift_install_basic_package_files(CMakeshift
    ARCH_INDEPENDENT
    NO_EXPORT
    COMPATIBILITY SameMajorVersion)
