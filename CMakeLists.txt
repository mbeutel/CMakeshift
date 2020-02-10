
# CMakeshift script library
# Author: Moritz Beutel


cmake_minimum_required(VERSION 3.14)

# Project definition
project(CMakeshift
    VERSION 3.8.1
    LANGUAGES)

# Build options
option(CMAKESHIFT_BUILD_DOCUMENTATION "Build documentation" OFF)
option(CMAKE_EXPORT_PACKAGE_REGISTRY "Export to user package registry" OFF)

# Targets
if(CMAKESHIFT_BUILD_DOCUMENTATION)
    add_subdirectory(doc)
endif()

# Installation
set(CMAKE_SIZEOF_VOID_P "") # suppresses warning about unknown target in GNUInstallDirs
include(GNUInstallDirs) # for CMAKE_INSTALL_DATADIR
include(cmake/CMakeshift/InstallBasicPackageFiles.cmake)
set(CMakeshift_BUILD_DATADIR "${PROJECT_SOURCE_DIR}/cmake")
set(CMakeshift_INSTALL_DATADIR "${CMAKE_INSTALL_DATADIR}/CMakeshift/cmake")
install(
    DIRECTORY "${CMakeshift_BUILD_DATADIR}/" # the trailing '/' is significant
    DESTINATION ${CMakeshift_INSTALL_DATADIR})
cmakeshift_install_basic_package_files(CMakeshift
    ARCH_INDEPENDENT
    NO_EXPORT
    COMPATIBILITY SameMajorVersion)

