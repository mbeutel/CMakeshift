
#.rst:
# FindNuma
# --------
#
# Find the Numa library.
#
# This will define the following variables::
#
#   Numa_FOUND    - True if the Numa library was found
#
# and the following imported targets::
#
#   Numa::Numa    - The Numa library
#
# The following macros can be defined prior to using this find module:
#
#   Numa_ROOT     - Optional path where to search for Numa

find_path(Numa_INCLUDE_DIR
    NAMES "numa.h"
    PATH_SUFFIXES "include")
find_library(Numa_LIBRARY
    NAMES numa
    PATH_SUFFIXES "lib" "lib64")

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Numa REQUIRED_VARS Numa_INCLUDE_DIR Numa_LIBRARY)

if(Numa_FOUND)
    # Define a target only if none has been defined yet.
    if(NOT TARGET Numa::Numa)
        add_library(Numa::Numa UNKNOWN IMPORTED)
        set_target_properties(Numa::Numa PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES ${Numa_INCLUDE_DIR}
            IMPORTED_LOCATION             ${Numa_LIBRARY})
    endif()
endif()

mark_as_advanced(Numa_INCLUDE_DIR Numa_LIBRARY)
