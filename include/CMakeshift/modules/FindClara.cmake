
#.rst:
# FindClara
# ---------
#
# Find the Clara header-only command-line parsing library.
#
# Look for the header file in the project's external include directory and in the system include directories.
#
# This will define the following variables::
#
#   Clara_FOUND    - True if the Clara library was found
#
# and the following imported targets::
#
#   Clara::Clara   - The Clara library
#
# The following macros can be defined prior to using this find module:
#
#   Clara_ROOT     - Optional path where to search for Clara

find_path(Clara_INCLUDE_DIR
    NAMES clara.hpp
    PATHS "${PROJECT_SOURCE_DIR}/external")

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Clara REQUIRED_VARS Clara_INCLUDE_DIR)

if(Clara_FOUND)
    set(Clara_INCLUDE_DIRS "${Clara_INCLUDE_DIR}")

    # Define a target only if none has been defined yet.
    if(NOT TARGET Clara::Clara)
        add_library(Clara::Clara INTERFACE IMPORTED)
        set_target_properties(Clara::Clara PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${Clara_INCLUDE_DIRS}")

        if(NOT Clara_FIND_QUIETLY)
            message(STATUS "Found Clara (find module at ${CMAKE_CURRENT_LIST_DIR}, headers at ${Clara_INCLUDE_DIRS})")
        endif()
    endif()
endif()

mark_as_advanced(Clara_INCLUDE_DIR)
