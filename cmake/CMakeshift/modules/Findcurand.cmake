
#.rst:
# FindCurand
# ----------
#
# Find the CUDA's library to generate random numbers
#
# This will define the following variables::
#
#   curand_VERSION - Version of curand in the form "major.minor.patch"
#
# and the following imported target::
#
#   curand::curand - curand library

find_path(curand_INCLUDE_DIR
    NAMES "curand.h"
    PATH_SUFFIXES "include")

if(curand_INCLUDE_DIR)
    file(READ "${curand_INCLUDE_DIR}/curand.h" CURAND_VERSION_HEADER)
    string(REGEX MATCH "CURAND_VER_MAJOR ([0-9]+)" DUMMY ${CURAND_VERSION_HEADER})
    set(CURAND_VER_MAJOR ${CMAKE_MATCH_1})
    string(REGEX MATCH "CURAND_VER_MINOR ([0-9]+)" DUMMY ${CURAND_VERSION_HEADER})
    set(CURAND_VER_MINOR ${CMAKE_MATCH_1})
    string(REGEX MATCH "CURAND_VER_PATCH ([0-9]+)" DUMMY ${CURAND_VERSION_HEADER})
    set(CURAND_VER_PATCH ${CMAKE_MATCH_1})
    set(curand_VERSION "${CURAND_VERSION_MAJOR}.${CURAND_VERSION_MINOR}.${CURAND_VERSION_PATCH}")
	set(CURAND_HINTS "${curand_INCLUDE_DIR}/../lib")
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(curand
    REQUIRED_VARS curand_INCLUDE_DIR
    VERSION_VAR curand_VERSION)

find_path(curand_LIBRARY_DIR NAMES "libcurand.so" PATH_SUFFIXES "lib" HINTS "${CURAND_HINTS}")

if(curand_FOUND AND curand_LIBRARY_DIR)
    # Define a target only if none has been defined yet.
    if(NOT TARGET curand::curand)
        add_library(curand::curand IMPORTED SHARED)
        set_target_properties(curand::curand PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${curand_INCLUDE_DIR}"
            IMPORTED_LOCATION "${curand_LIBRARY_DIR}/libcurand.so")
    endif()
endif()

mark_as_advanced(curand_INCLUDE_DIR)
