
#.rst:
# FindMS-GSL
# ----------
#
# Find the C++ Guidelines Support Library.
# The find module, the namespace and the target are named "MS-GSL" rather than "GSL" to avoid confusion
# with the GNU Scientific Library, commonly abbreviated as "GSL".
#
# This will define the following variables::
#
#   MS-GSL_FOUND   - True if the Microsoft GSL was found
#
# and the following imported targets::
#
#   MS-GSL::GSL    - The Microsoft GSL library (legacy alias)
#   MS-GSL::MS-GSL - The Microsoft GSL library

find_path(MS-GSL_INCLUDE_DIR
    NAMES "gsl/gsl_algorithm"
    PATH_SUFFIXES "include")

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(MS-GSL REQUIRED_VARS MS-GSL_INCLUDE_DIR)

if(MS-GSL_FOUND)
    # Define a target only if none has been defined yet.
    if(NOT TARGET MS-GSL::MS-GSL)
        add_library(MS-GSL::MS-GSL INTERFACE IMPORTED)
        set_target_properties(MS-GSL::MS-GSL PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${MS-GSL_INCLUDE_DIR}")
    endif()
    if(NOT TARGET MS-GSL::GSL)
        add_library(MS-GSL::GSL INTERFACE IMPORTED)
        set_target_properties(MS-GSL::GSL PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${MS-GSL_INCLUDE_DIR}")
    endif()
endif()

mark_as_advanced(MS-GSL_INCLUDE_DIR)
