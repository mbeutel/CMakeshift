
# FindNuma
# --------
#
# Find the Numa Library.
#
# Look for the header file in the project's external include directory, in the NUMA_ROOT_DIR directory,
# and in the system include directories.

find_path(Numa_INCLUDE_DIR
    NAMES numa.h
    PATHS "${PROJECT_SOURCE_DIR}/external" "${NUMA_ROOT_DIR}"
    PATH_SUFFIXES "/include")
find_library(Numa_LIBRARY
    NAMES numa
    PATHS "${PROJECT_SOURCE_DIR}/external" "${NUMA_ROOT_DIR}"
    PATH_SUFFIXES "/lib" "/lib64")

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Numa REQUIRED_VARS Numa_INCLUDE_DIR Numa_LIBRARY)

if(Numa_FOUND)
    set(Numa_INCLUDE_DIRS "${Numa_INCLUDE_DIR}")
    set(Numa_LIBRARIES "${Numa_LIBRARY}")

    # Define a target only if none has been defined yet.
    if(NOT TARGET Numa::Numa)
        add_library(Numa::Numa INTERFACE IMPORTED)
        set_target_properties(Numa::Numa PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${Numa_INCLUDE_DIRS}"
            INTERFACE_LINK_LIBRARIES      "${Numa_LIBRARIES}")

        message(STATUS "Found Numa (find module at ${CMAKE_CURRENT_LIST_DIR}, headers at ${Numa_INCLUDE_DIRS}, library at ${Numa_LIBRARIES})")
    endif()
endif()

mark_as_advanced(Numa_INCLUDE_DIR Numa_LIBRARY)
