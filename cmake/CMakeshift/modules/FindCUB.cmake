
#.rst:
# FindCUB
# ----------
#
# Find the CUB library
#
# This find module will define the imported target::
#
#   CUB::CUB - CUB header-only CUDA library

find_path(CUB_INCLUDE_DIR
    NAMES "cub/cub.cuh"
    PATH_SUFFIXES "include")

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(CUB
    REQUIRED_VARS CUB_INCLUDE_DIR)

if(CUB_INCLUDE_DIR)
    # Define a target only if none has been defined yet.
    if(NOT TARGET CUB::CUB)
        add_library(CUB::CUB INTERFACE IMPORTED)
        set_target_properties(CUB::CUB PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${CUB_INCLUDE_DIR}")
    endif()
endif()

mark_as_advanced(CUB_INCLUDE_DIR)
