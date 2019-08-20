
#.rst:
# FindNuma
# --------
#
# Find the Numa library.
#
# Look for the header file in the project's external include directory, in the NUMA_ROOT_DIR directory,
# and in the system include directories.
#
# This will define the following variables::
#
#   NUMA_FOUND    - True if the Numa library was found
#
# and the following imported targets::
#
#   Numa::Numa    - The Numa library
#
# The following macros can be defined prior to using this find module:
#
#   NUMA_ROOT     - Optional path where to search for Numa

find_path(NUMA_INCLUDE_DIR
    NAMES numa.h
    PATHS "${PROJECT_SOURCE_DIR}/external" "${PROJECT_SOURCE_DIR}/external/numa"
    PATH_SUFFIXES "include")
find_library(NUMA_LIBRARY
    NAMES numa
    PATHS "${PROJECT_SOURCE_DIR}/external" "${PROJECT_SOURCE_DIR}/external/numa"
    PATH_SUFFIXES "lib" "lib64")

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Numa REQUIRED_VARS NUMA_INCLUDE_DIR NUMA_LIBRARY)

if(NUMA_FOUND)
    # Define a target only if none has been defined yet.
    if(NOT TARGET Numa::Numa)
        add_library(Numa::Numa UNKNOWN IMPORTED)
        set_target_properties(Numa::Numa PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES ${NUMA_INCLUDE_DIR}
            IMPORTED_LOCATION             ${NUMA_LIBRARY})
    endif()
endif()

mark_as_advanced(NUMA_INCLUDE_DIR NUMA_LIBRARY)

