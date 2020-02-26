
#.rst:
# FindThrust
# ----------
#
# Find the Thrust C++ library.
#
# This will define the following variables::
#
#   Thrust_VERSION - Version of Thrust in the form "major.minor.patch"
#
# and the following imported target::
#
#   Thrust::Thrust - Thrust header-only library

find_path(Thrust_INCLUDE_DIR
    NAMES "thrust/version.h"
    PATH_SUFFIXES "include")

if(Thrust_INCLUDE_DIR)
    file(READ "${Thrust_INCLUDE_DIR}/thrust/version.h" THRUST_VERSION_HEADER)
    string(REGEX MATCH "THRUST_VERSION ([0-9]+)" DUMMY ${THRUST_VERSION_HEADER})
    set(THRUST_VERSION_RAW ${CMAKE_MATCH_1})
    math(EXPR THRUST_VERSION_MAJOR "(${THRUST_VERSION_RAW} / 100000)")
    math(EXPR THRUST_VERSION_MINOR "(${THRUST_VERSION_RAW} / 100) % 1000")
    math(EXPR THRUST_VERSION_PATCH "${THRUST_VERSION_RAW} % 100")
    set(Thrust_VERSION "${THRUST_VERSION_MAJOR}.${THRUST_VERSION_MINOR}.${THRUST_VERSION_PATCH}")
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Thrust
    REQUIRED_VARS Thrust_INCLUDE_DIR
    VERSION_VAR Thrust_VERSION)

if(Thrust_FOUND)
    # Define a target only if none has been defined yet.
    if(NOT TARGET Thrust::Thrust)
        add_library(Thrust::Thrust INTERFACE IMPORTED)
        set_target_properties(Thrust::Thrust PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${Thrust_INCLUDE_DIR}")
    endif()
endif()

mark_as_advanced(Thrust_INCLUDE_DIR)
