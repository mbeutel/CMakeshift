# FindMS-GSL
# ----------
#
# Find the C++ Guideline Support Library.
# The find module, the namespace and the target are named "MS-GSL" rather than "GSL" to avoid confusion
# with the GNU Scientific Library, commonly abbreviated as "GSL".
#
# Look for the header file in the project's external include directory and in the system include directories.
# GSL may reside in a system include directory if it has been installed with vcpkg.
find_path(MS-GSL_INCLUDE_DIR "gsl/gsl_algorithm"
    PATHS "${PROJECT_SOURCE_DIR}/external"
    PATH_SUFFIXES "/include")
if(MS-GSL_INCLUDE_DIR)
    set(MS-GSL_INCLUDE_DIRS "${MS-GSL_INCLUDE_DIR}")
endif()

# If the header file has been found, define an imported target for it.
if(MS-GSL_INCLUDE_DIRS)
    add_library(MS-GSL::MS-GSL INTERFACE IMPORTED)
    set_target_properties(MS-GSL::MS-GSL PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${MS-GSL_INCLUDE_DIRS}")
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(MS-GSL REQUIRED_VARS MS-GSL_INCLUDE_DIR)

mark_as_advanced(MS-GSL_INCLUDE_DIR MS-GSL_INCLUDE_DIRS)
