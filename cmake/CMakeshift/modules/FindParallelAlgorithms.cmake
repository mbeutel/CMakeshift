
#.rst:
# FindParallelAlgorithms
# ----------------------
#
# Define an imported target that represents the features provided by the C++17 <execution> header.
# GCC 9's implementation of parallel algorithm execution depends on Intel's Threading Building Blocks (TBB), hence this
# package introduces a transitive dependency to TBB when using GCC.
#
# This will define the following variables::
#
#   ParallelAlgorithms_FOUND - True
#
# and the following imported targets::
#
#   ParallelAlgorithms::ParallelAlgorithms - Imported target that carries linker flags required to use <execution> on all platforms.


set(Filesystem_FOUND True)

if(NOT TARGET ParallelAlgorithms::ParallelAlgorithms)
    # Define a target only if none has been defined yet.
    add_library(ParallelAlgorithms::ParallelAlgorithms INTERFACE IMPORTED)

    # GCC 9's libstdc++ implements <execution> but currently requires that we link to Intel TBB when using it.
    if((CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX) AND CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 9)
        find_package(TBB REQUIRED)
        set_property(TARGET ParallelAlgorithms::ParallelAlgorithms PROPERTY INTERFACE_LINK_LIBRARIES TBB::tbb)
    endif()
endif()
