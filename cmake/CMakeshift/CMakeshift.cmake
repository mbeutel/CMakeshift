# CMakeshift.cmake
# Author: Moritz Beutel

# make CMakeshift script directory accessible to expose the find modules in the "modules" subdirectory
set(CMAKESHIFT_MODULE_DIR "${CMAKE_CURRENT_LIST_DIR}/modules")

# set CMAKESHIFT_LIB_SUFFIX to "64" for 64-bit Linux distributions except for Debian and Arch
if(CMAKE_SYSTEM_NAME MATCHES "Linux"
   AND NOT DEFINED CMAKESHIFT_LIB_SUFFIX
   AND NOT CMAKE_CROSSCOMPILING
   AND CMAKE_SIZEOF_VOID_P EQUAL "8"
   AND NOT EXISTS "/etc/debian_version"
   AND NOT EXISTS "/etc/arch-release")
    set(CMAKESHIFT_LIB_SUFFIX "64")
endif()

function(CMAKESHIFT_UPDATE_CACHE_VARIABLE VAR_NAME VALUE)
    get_property(HELP_STRING CACHE ${VAR_NAME} PROPERTY HELPSTRING)
    get_property(VAR_TYPE CACHE ${VAR_NAME} PROPERTY TYPE)
    set(${VAR_NAME} ${VALUE} CACHE ${VAR_TYPE} "${HELP_STRING}" FORCE)
endfunction()

# Parse version info from the given header file.
# The header file should #define the macros "${DEF_NAME}_VERSION_MAJOR", "${DEF_NAME}_VERSION_MINOR", and "${DEF_NAME}_VERSION_PATCH".
function(CMAKESHIFT_PARSE_SEMANTIC_VERSION VAR_NAME DEF_NAME HDR_FILE)
    file(STRINGS "${HDR_FILE}" HDR_FILE_STRINGS)
    string(REGEX REPLACE ".*#define[ \t]+${DEF_NAME}_VERSION_MAJOR[ \t]+([0-9]+).*" "\\1" SEMANTIC_VERSION_MAJOR "${HDR_FILE_STRINGS}")
    string(REGEX REPLACE ".*#define[ \t]+${DEF_NAME}_VERSION_MINOR[ \t]+([0-9]+).*" "\\1" SEMANTIC_VERSION_MINOR "${HDR_FILE_STRINGS}")
    string(REGEX REPLACE ".*#define[ \t]+${DEF_NAME}_VERSION_PATCH[ \t]+([0-9]+).*" "\\1" SEMANTIC_VERSION_PATCH "${HDR_FILE_STRINGS}")
    set(SEMANTIC_VERSION "${SEMANTIC_VERSION_MAJOR}.${SEMANTIC_VERSION_MINOR}.${SEMANTIC_VERSION_PATCH}")
    if(NOT ("${SEMANTIC_VERSION}" MATCHES "^[0-9]+\\.[0-9]+\\.[0-9]+$"))
        message(FATAL_ERROR "Failed to parse semantic version from header file ${HDR_FILE}; parse result: ${SEMANTIC_VERSION}")
    endif()
    set(${VAR_NAME} "${SEMANTIC_VERSION}" PARENT_SCOPE)
endfunction()

# Parse version info from the given header file.
# The header file should contain a version string of the form "${DEF_PREFIX}<major>.<minor>.<patch>".
# DEF_PREFIX uses regular expression syntax.
function(CMAKESHIFT_PARSE_SEMANTIC_VERSION_COMMENT VAR_NAME DEF_PREFIX HDR_FILE)
    file(STRINGS "${HDR_FILE}" HDR_FILE_STRINGS)
    string(REGEX REPLACE ".*${DEF_PREFIX}([0-9]+(\\.[0-9]+)?(\\.[0-9]+)?).*" "\\1" SEMANTIC_VERSION "${HDR_FILE_STRINGS}")
    if(NOT ("${SEMANTIC_VERSION}" MATCHES "^[0-9]+(\\.[0-9]+)?(\\.[0-9]+)?$"))
        message(FATAL_ERROR "Failed to parse semantic version from header file ${HDR_FILE}; parse result: ${SEMANTIC_VERSION}")
    endif()
    set(${VAR_NAME} "${SEMANTIC_VERSION}" PARENT_SCOPE)
endfunction()

# Parse binary version info from the given header file.
# The header file should #define the macro "${DEF_NAME}_VERSION_API".
function(CMAKESHIFT_PARSE_API_VERSION VAR_NAME DEF_NAME HDR_FILE)
    file(STRINGS "${HDR_FILE}" HDR_FILE_STRINGS)
    string(REGEX REPLACE ".*#define[ \t]+${DEF_NAME}_VERSION_API[ \t]+([0-9]+).*" "\\1" API_VERSION "${HDR_FILE_STRINGS}")
    if(NOT ("${API_VERSION}" MATCHES "^[0-9]+$"))
        message(FATAL_ERROR "Failed to parse API version from header file ${HDR_FILE}; parse result: ${API_VERSION}")
    endif()
    set(${VAR_NAME} "${API_VERSION}" PARENT_SCOPE)
endfunction()

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

# Similar to find_path() but works for files and directories alike.
# The base path under which the relative path was found is written to VAR_NAME upon success.
function(CMAKESHIFT_FIND_PATH VAR_NAME NEEDLE HAYSTACK)
    unset(${VAR_NAME} PARENT_SCOPE)
    foreach(_CMAKESHIFT_TMP_PATH IN LISTS HAYSTACK)
        if(EXISTS "${_CMAKESHIFT_TMP_PATH}/${NEEDLE}")
            set(${VAR_NAME} "${_CMAKESHIFT_TMP_PATH}" PARENT_SCOPE)
            break()
        endif()
    endforeach()
endfunction()

# Install the listed find modules found in the given find module path.
function(CMAKESHIFT_INSTALL_FIND_MODULES)
    set(oneValueArgs DESTINATION)
    set(multiValueArgs FIND_MODULE_PATH FIND_MODULES)
    cmake_parse_arguments(_MK_IFM "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    
    foreach(MODULE IN LISTS _MK_IFM_FIND_MODULES)
        cmakeshift_find_path(_MK_MODULE_DIR "Find${MODULE}.cmake" "${_MK_IFM_FIND_MODULE_PATH}")
        if(NOT _MK_MODULE_DIR)
            message(FATAL_ERROR "File 'Find${MODULE}.cmake' not found in interface module search path: ${_MK_IFM_FIND_MODULE_PATH}")
        endif()
        install(
            FILES "${_MK_MODULE_DIR}/Find${MODULE}.cmake"
            DESTINATION "${_MK_IFM_DESTINATION}")
    endforeach()
endfunction()
