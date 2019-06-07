
# CMakeshift
# Install.cmake
# Author: Moritz Beutel


# Get the CMakeshift script include directory.
get_filename_component(CMAKESHIFT_SCRIPT_DIR "${CMAKE_CURRENT_LIST_DIR}" DIRECTORY)


# Wrapper of CMake's INSTALL() command which takes care of deployment of dependencies.
#
#     install(...)
#
macro(INSTALL OPTION)

    _install(${ARGV})

    if("${OPTION}" STREQUAL "TARGETS")
        include(${CMAKESHIFT_SCRIPT_DIR}/detail/InstallDependencies.cmake)
        _cmakeshift_install_targets(${ARGN})
    endif()

endmacro()
