
#.rst:
# FindCMakeshift
# --------------
#
# Find the CMakeshift package.
#
# This will define the following variables::
#
#   CMakeshift_FOUND      - True if the CMakeshift package with the corresponding version was found
#   CMakeshift_SCRIPT_DIR - Path where CMakeshift scripts are located

set(CMakeshift_MODULE_VERSION 4.0.0)
set(CMakeshift_SCRIPT_DIR ${CMAKE_CURRENT_LIST_DIR})

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(CMakeshift
    REQUIRED_VARS CMakeshift_SCRIPT_DIR
    VERSION_VAR CMakeshift_MODULE_VERSION)

# Fall back to linking Release builds of library targets when building with MinSizeRel or RelWithDebInfo.
if(NOT DEFINED CMAKE_MAP_IMPORTED_CONFIG_MINSIZEREL)
    set(CMAKE_MAP_IMPORTED_CONFIG_MINSIZEREL "MinSizeRel;Release")
endif()
if(NOT DEFINED CMAKE_MAP_IMPORTED_CONFIG_RELWITHDEBINFO)
    set(CMAKE_MAP_IMPORTED_CONFIG_RELWITHDEBINFO "RelWithDebInfo;Release")
endif()

mark_as_advanced(CMakeshift_SCRIPT_DIR)
