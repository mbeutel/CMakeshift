
# CMakeshift
# SetLibraryVersion.cmake
# Author: Moritz Beutel


# Set the library build version and API version, handling both static and shared libraries.
function(CMAKESHIFT_SET_LIBRARY_VERSION TARGET_NAME TARGET_VERSION TARGET_APIVERSION)
    set_target_properties(${TARGET_NAME} PROPERTIES
        VERSION ${TARGET_VERSION}
        INTERFACE_LIB_APIVERSION ${TARGET_APIVERSION})
    set_property(
        TARGET ${TARGET_NAME}
        APPEND PROPERTY COMPATIBLE_INTERFACE_STRING LIB_APIVERSION)
    get_target_property(TARGET_TYPE ${TARGET_NAME} TYPE)
    if(${TARGET_TYPE} STREQUAL SHARED_LIBRARY)
        set_target_properties(${TARGET_NAME} PROPERTIES
            SOVERSION ${TARGET_APIVERSION})
    endif()
endfunction()
