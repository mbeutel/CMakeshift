# FindGSL
# ---------
#
# Find the C++ Guideline Support Library.
#
# Look for the header file in the project's external include directory and in the system include directories.
# GSL may reside in a system include directory if it has been installed with vcpkg.
find_path(GSL_INCLUDE_DIR "gsl/gsl_algorithm"
    PATHS "${PROJECT_SOURCE_DIR}/external"
    PATH_SUFFIXES "/include")
if(GSL_INCLUDE_DIR)
    set(GSL_INCLUDE_DIRS "${GSL_INCLUDE_DIR}")
endif()

# If the header file has been found, define an imported target for it.
if(GSL_INCLUDE_DIRS)
    add_library(GSL::GSL INTERFACE IMPORTED)
    set_target_properties(GSL::GSL PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${GSL_INCLUDE_DIRS}")
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(GSL REQUIRED_VARS GSL_INCLUDE_DIR)

mark_as_advanced(GSL_INCLUDE_DIR GSL_INCLUDE_DIRS)
