
# CMakeshift script library
# Author: Moritz Beutel
# CMakeshift documentation targets


cmake_minimum_required(VERSION 3.14)

# Dependencies
list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake/CMakeshift/modules")
find_package(Sphinx REQUIRED)

# Sphinx configuration
set(SPHINX_SOURCE ${CMAKE_CURRENT_SOURCE_DIR})
set(SPHINX_BUILD "${CMAKE_CURRENT_BINARY_DIR}/sphinx/CMakeshift")
set(SPHINX_INDEX_FILE "${SPHINX_BUILD}/index.html")

set(conf_copyright "Copyright 2018-2019 Moritz Beutel")
set(conf_docs "${PROJECT_SOURCE_DIR}/doc")
set(conf_path "${CMAKE_CURRENT_SOURCE_DIR}")
set(conf_version "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}")
set(conf_release "${PROJECT_NAME} ${PROJECT_VERSION}")
configure_file(conf.py.in conf.py @ONLY)

# Sphinx target
file(GLOB SPHINX_MANUAL_SOURCES "${conf_docs}/modules/*.rst")
file(GLOB SPHINX_CMAKE_SOURCES "${PROJECT_SOURCE_DIR}/cmake/CMakeshift/*.cmake")
add_custom_command(
    OUTPUT ${SPHINX_INDEX_FILE}
    COMMAND ${Sphinx_EXECUTABLE}
        -c ${CMAKE_CURRENT_BINARY_DIR}
        -b html ${SPHINX_SOURCE} ${SPHINX_BUILD}
    DEPENDS
        ${SPHINX_MANUAL_SOURCES} ${SPHINX_CMAKE_SOURCES}
        "${CMAKE_CURRENT_SOURCE_DIR}/index.rst"
    MAIN_DEPENDENCY "${CMAKE_CURRENT_BINARY_DIR}/conf.py"
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "Generating documentation with Sphinx")
add_custom_target(sphinx
    DEPENDS ${SPHINX_INDEX_FILE})

# Installation
install(
    DIRECTORY ${SPHINX_BUILD} # no trailing '/' desired
    TYPE DOC)
