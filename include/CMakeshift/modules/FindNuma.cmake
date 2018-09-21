#
# Copied from caffe2 and modified to expose a proper imported target
#
# Find the Numa libraries
#
# The following variables are optionally searched for defaults
#  NUMA_ROOT_DIR:    Base directory where all Numa components are found
#
# The following are set after configuration is done:
#  NUMA_FOUND
#  Numa_INCLUDE_DIR
#  Numa_LIBRARIES


if( NOT TARGET Numa::Numa )
  find_path(
      Numa_INCLUDE_DIR NAMES numa.h
      PATHS ${NUMA_ROOT_DIR} ${NUMA_ROOT_DIR}/include)

  find_library(
      Numa_LIBRARIES NAMES numa
      PATHS ${NUMA_ROOT_DIR} ${NUMA_ROOT_DIR}/lib)

  include(FindPackageHandleStandardArgs)
  find_package_handle_standard_args(
      Numa DEFAULT_MSG Numa_INCLUDE_DIR Numa_LIBRARIES)


  if(NUMA_FOUND)
    add_library( Numa::Numa INTERFACE IMPORTED )
    set_target_properties( Numa::Numa PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${Numa_INCLUDE_DIR}"
      INTERFACE_LINK_LIBRARIES      "${Numa_LIBRARIES}"
      )
    message(
        STATUS
        "Found Numa  (include: ${Numa_INCLUDE_DIR}, library: ${Numa_LIBRARIES})")
    mark_as_advanced(Numa_INCLUDE_DIR Numa_LIBRARIES)
  endif()
endif()
