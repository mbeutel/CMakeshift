
#.rst:
# FindHedley
# ----------
#
# Find the Hedley header-only library.
#
# This will define the following variables::
#
#   Hedley_FOUND    - True if the Hedley header was found
#
# and the following imported targets::
#
#   Hedley::Hedley  - The Hedley header library
#
# The following macros can be defined prior to using this find module:
#
#   Hedley_ROOT     - Optional path where to search for Hedley

find_path(Hedley_INCLUDE_DIR
    NAMES hedley.h
    PATH_SUFFIXES "include")

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Hedley REQUIRED_VARS Hedley_INCLUDE_DIR)

if(Hedley_FOUND)
    # Define a target only if none has been defined yet.
    if(NOT TARGET Hedley::Hedley)
        add_library(Hedley::Hedley INTERFACE IMPORTED)
        set_target_properties(Hedley::Hedley PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${Hedley_INCLUDE_DIR}")
    endif()
endif()

mark_as_advanced(Hedley_INCLUDE_DIR)
