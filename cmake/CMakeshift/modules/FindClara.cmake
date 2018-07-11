
# FindClara
# ---------
#
# Find the Clara header-only command-line parsing library.
#
# Look for the header file in the project's external include directory and in the system include directories.
# Clara may reside in a system include directory if it has been installed with vcpkg.
find_path(Clara_INCLUDE_DIR clara.hpp
    PATHS "${PROJECT_SOURCE_DIR}/external"
    PATH_SUFFIXES "/include")
if(Clara_INCLUDE_DIR)
    set(Clara_INCLUDE_DIRS "${Clara_INCLUDE_DIR}")
endif()

# If the header file has been found, define an imported target for it.
if(Clara_INCLUDE_DIRS)
    add_library(Clara::Clara INTERFACE IMPORTED)
    set_target_properties(Clara::Clara PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${Clara_INCLUDE_DIRS}")
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Clara REQUIRED_VARS Clara_INCLUDE_DIR)

mark_as_advanced(Clara_INCLUDE_DIR Clara_INCLUDE_DIRS)
