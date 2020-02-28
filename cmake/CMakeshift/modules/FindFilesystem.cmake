
#.rst:
# FindFilesystem
# --------------
#
# Define an imported target that represents the features provided by the C++17 <filesystem> header.
#
# This will define the following variables::
#
#   Filesystem_FOUND - True
#
# and the following imported targets::
#
#   Filesystem::Filesystem - Imported target that carries linker flags required to use <filesystem> on all platforms.


set(Filesystem_FOUND True)

if(NOT TARGET Filesystem::Filesystem)
    # Define a target only if none has been defined yet.
    add_library(Filesystem::Filesystem INTERFACE IMPORTED)

    # GCC 8's libstdc++ implements <filesystem> but currently requires that we link to libstdc++fs when using it.
    if((CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX) AND CMAKE_CXX_COMPILER_VERSION VERSION_LESS 9.1)
        set_property(TARGET Filesystem::Filesystem PROPERTY INTERFACE_LINK_LIBRARIES "stdc++fs")
    endif()
endif()
