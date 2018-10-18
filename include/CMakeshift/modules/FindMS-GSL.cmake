
#.rst:
# FindMS-GSL
# ----------
#
# Find the C++ Guideline Support Library.
# The find module, the namespace and the target are named "MS-GSL" rather than "GSL" to avoid confusion
# with the GNU Scientific Library, commonly abbreviated as "GSL".
#
# Look for the header file in the project's external include directory and in the system include directories.
#
# This will define the following variables::
#
#   MS-GSL_FOUND    - True if the MS-GSL library was found
#
# and the following imported targets::
#
#   MS-GSL::MS-GSL  - The MS-GSL library

find_path(MS-GSL_INCLUDE_DIR
    NAMES "gsl/gsl_algorithm"
    PATHS "${PROJECT_SOURCE_DIR}/external/include" "${PROJECT_SOURCE_DIR}/external/ms-gsl/include")

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(MS-GSL REQUIRED_VARS MS-GSL_INCLUDE_DIR)

if(MS-GSL_FOUND)
    set(MS-GSL_INCLUDE_DIRS "${MS-GSL_INCLUDE_DIR}")

    # Define a target only if none has been defined yet.
    if(NOT TARGET MS-GSL::MS-GSL)
        add_library(MS-GSL::MS-GSL INTERFACE IMPORTED)
        set_target_properties(MS-GSL::MS-GSL PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${MS-GSL_INCLUDE_DIRS}")

        if(NOT MS-GSL_FIND_QUIETLY)
            message(STATUS "Found MS-GSL (find module at ${CMAKE_CURRENT_LIST_DIR}, headers at ${MS-GSL_INCLUDE_DIRS})")
        endif()
    endif()
endif()

mark_as_advanced(MS-GSL_INCLUDE_DIR)
