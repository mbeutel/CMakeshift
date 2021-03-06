
# CMakeshift
# detail/Settings-Default.cmake
# Author: Moritz Beutel



set(_CMAKE_CUMULATIVE_SETTING_default
    "default-base"
    "default-experimental"
    "default-output-directory"
    "default-utf8-source"
    "default-windows-unicode"
    "default-conformance"
    "default-debugjustmycode"
    "default-debugdevicecode"
    "default-shared"
    "default-inlines-hidden"
    "diagnostics-pedantic"
    "diagnostics-paranoid")

list(APPEND _CMAKESHIFT_KNOWN_CUMULATIVE_SETTINGS
    "default")

list(APPEND _CMAKESHIFT_KNOWN_SETTINGS
    "default-base"
    "default-experimental"
    "default-output-directory"
    "default-utf8-source"
    "utf8-codepage"
    "default-windows-unicode"
    "default-conformance"
    "default-debugjustmycode"
    "default-debugdevicecode"
    "default-shared"
    "default-inlines-hidden")


if(NOT CMAKESHIFT_PERMIT_IN_SOURCE_BUILD)
    get_filename_component(_CMAKESHIFT_SOURCE_DIR "${CMAKE_SOURCE_DIR}" REALPATH)
    get_filename_component(_CMAKESHIFT_BINARY_DIR "${CMAKE_BINARY_DIR}" REALPATH)
    if("${_CMAKESHIFT_SOURCE_DIR}" STREQUAL "${_CMAKESHIFT_BINARY_DIR}")
        message(WARNING "cmakeshift_target_compile_settings() sanity check: the project source directory is identical to the build directory. \
This practice is discouraged. \
Delete all build artifacts in the source directory (CMakeCache.txt, CMakeFiles/, cmake_install.cmake) and configure the project again with a different build directory. \
If you need to build in-source, you can disable this sanity check by setting CMAKESHIFT_PERMIT_IN_SOURCE_BUILD=ON.")
    endif()
endif()


# Sanity check: if all of CMAKE_*_FLAGS_* are defined but empty, CMake failed to find the compiler in the first run.
# This is dangerous because the default compiler flags will be silently missing. The recommended way out is to purge the
# build directory and to rebuild.
if(NOT CMAKESHIFT_PERMIT_EMPTY_FLAGS)
    foreach(LANG IN ITEMS C CXX CUDA)
        if(DEFINED CMAKE_${LANG}_COMPILER)
            set(_CMAKESHIFT_SANITYCHECK_PASS FALSE)
            foreach(CFG IN ITEMS DEBUG MINSIZEREL RELEASE RELWITHDEBINFO)
                if(NOT DEFINED CMAKE_${LANG}_FLAGS_${CFG} OR NOT "${CMAKE_${LANG}_FLAGS_${CFG}}" STREQUAL "")
                    set(_CMAKESHIFT_SANITYCHECK_PASS TRUE)
                    break()
                endif()
            endforeach()

            if(NOT _CMAKESHIFT_SANITYCHECK_PASS)
                message(FATAL_ERROR "cmakeshift_target_compile_settings() sanity check: The default compile flags for ${LANG} are empty. \
This usually happens if CMake fails to find a particular compiler during configuration. \
Please purge the build directory, then make sure the compilers are available and configure the project again. \
If you need to build with empty default compile flags, you can disable this sanity check by setting CMAKESHIFT_PERMIT_EMPTY_FLAGS=ON.")
            endif()
        endif()
    endforeach()
endif()


function(_CMAKESHIFT_SETTINGS_DEFAULT)

    # variables available from calling scope: SETTING, HAVE_<LANG>, PASSTHROUGH, VAL, TARGET_NAME, SCOPE, LB, RB

    if(SETTING STREQUAL "default-base")
        # default options everyone can agree on
        if(MSVC)
            # enable /bigobj switch to permit more than 2^16 COMDAT sections per .obj file (can be useful in heavily templatized code)
            target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}/bigobj${RB}")

            # remove unreferenced COMDATs to improve linker throughput
            target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}/Zc:inline${RB}") # available since pre-modern VS 2013 Update 2
        endif()

    elseif(SETTING STREQUAL "default-experimental")
        if(MSVC AND CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 19.21) # available since VS 2019 16.1
            # enable new lambda processor to improve diagnostics and fix some constexpr scoping issues
            target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}/experimental:newLambdaProcessor${RB}")
        endif()

        if(HAVE_CUDA AND CMAKE_CUDA_COMPILER_ID MATCHES "NVIDIA") # NVCC
            # permit cross-domain calls during constexpr evaluation
            target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}$<$<COMPILE_LANGUAGE:CUDA>:--expt-relaxed-constexpr>${RB}")

            # permit `__host__ __device__` annotation for lambda functions
            target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}$<$<COMPILE_LANGUAGE:CUDA>:--expt-extended-lambda>${RB}")
        endif()

    elseif(SETTING STREQUAL "default-output-directory")
        # place binaries in ${PROJECT_BINARY_DIR} unless target properties are set
        get_target_property(_TARGET_TYPE ${TARGET_NAME} TYPE)
        if(_TARGET_TYPE STREQUAL SHARED_LIBRARY OR _TARGET_TYPE STREQUAL MODULE_LIBRARY OR _TARGET_TYPE STREQUAL EXECUTABLE)
            get_target_property(_DIR ${TARGET_NAME} RUNTIME_OUTPUT_DIRECTORY)
            if(NOT _DIR)
                set_target_properties(${TARGET_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}")
            endif()
            get_target_property(_DIR ${TARGET_NAME} LIBRARY_OUTPUT_DIRECTORY)
            if(NOT _DIR)
                set_target_properties(${TARGET_NAME} PROPERTIES LIBRARY_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}")
            endif()
        endif()

    elseif(SETTING STREQUAL "default-utf8-source")
        # source files use UTF-8 encoding
        if(MSVC)
            target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}/utf-8${RB}")
        endif()

    elseif(SETTING STREQUAL "utf8-codepage")
        # set UTF-8 as default narrow codepage on Windows
        if(MSVC)
            get_target_property(_TARGET_TYPE ${TARGET_NAME} TYPE)
            if(_TARGET_TYPE STREQUAL EXECUTABLE)
                set(WINDOWS_SDK_VERSION "")
                if(CMAKE_MT MATCHES "Windows Kits\/.*\/bin\/([^\/]+)\/")
                    set(WINDOWS_SDK_VERSION "${CMAKE_MATCH_1}")
                endif()
                if(NOT WINDOWS_SDK_VERSION)
                    message(WARNING "cmakeshift_target_compile_settings(): Setting \"utf8-codepage\": Cannot set UTF-8 codepage in manifest: Windows SDK directory not found (bug in CMakeshift? CMAKE_MT=${CMAKE_MT})")
                elseif(WINDOWS_SDK_VERSION VERSION_LESS 10.0.18362.0) # Windows 10 1903 SDK
                    message(WARNING "cmakeshift_target_compile_settings(): Setting \"utf8-codepage\": Cannot set UTF-8 codepage in manifest: Windows SDK too old (found ${WINDOWS_SDK_VERSION}, need at least 10.0.18362.0)")
                else()
                    target_sources(${TARGET_NAME} ${SCOPE} "${LB}${CMAKESHIFT_SCRIPT_DIR}/CMakeshift/detail/utf8.manifest${RB}")
                endif()
            endif()
        endif()

    elseif(SETTING STREQUAL "default-windows-unicode")
        # UNICODE and _UNICODE are defined on Windows
        target_compile_definitions(${TARGET_NAME} ${SCOPE} "${LB}$<$<PLATFORM_ID:Windows>:UNICODE>${RB}" "${LB}$<$<PLATFORM_ID:Windows>:_UNICODE>${RB}")

    elseif(SETTING STREQUAL "default-conformance")
        # configure compilers to be ISO C++ conformant

        # disable language extensions
        if(HAVE_C)
            set_target_properties(${TARGET_NAME} PROPERTIES C_EXTENSIONS OFF)
        endif()
        if(HAVE_CXX)
            set_target_properties(${TARGET_NAME} PROPERTIES CXX_EXTENSIONS OFF)
        endif()

        if(MSVC)
            # make `volatile` behave as specified by the language standard, as opposed to the quasi-atomic semantics VC++ implements by default
            target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}/volatile:iso${RB}")

            # enable permissive mode (prefer already rejuvenated parts of compiler for better conformance)
            if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 19.10)
                target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}/permissive-${RB}") # available since VS 2017 15.0
            endif()

            # enable "extern constexpr" support
            if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 19.13)
                target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}/Zc:externConstexpr${RB}") # available since VS 2017 15.6
            endif()

            # enable updated __cplusplus macro value
            if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 19.14)
                target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}/Zc:__cplusplus${RB}") # available since VS 2017 15.7
            endif()
        endif()

    elseif(SETTING STREQUAL "default-debugjustmycode")
        # enable debugging aids
        if(MSVC)
            # enable Just My Code for debugging convenience
            
            # use target property VS_JUST_MY_CODE_DEBUGGING if possible
            if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.15)
                set_target_properties(${TARGET_NAME} PROPERTIES VS_JUST_MY_CODE_DEBUGGING "${LB}$<$<CONFIG:Debug>:ON>${RB}")
                
            elseif(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 19.15)
                target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}$<$<CONFIG:Debug>:${PASSTHROUGH}/JMC>${RB}") # available since VS 2017 15.8
            endif()
        endif()

    elseif(SETTING STREQUAL "default-debugdevicecode")
        # enable device code debugging
        if(HAVE_CUDA)
            if(CMAKE_CUDA_COMPILER_ID MATCHES "NVIDIA")
                target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}$<$<COMPILE_LANGUAGE:CUDA>:$<$<CONFIG:Debug>:--device-debug>>${RB}" "${LB}$<$<COMPILE_LANGUAGE:CUDA>:$<$<CONFIG:RelWithDebInfo>:--generate-line-info>>${RB}")

            else()
                message(WARNING "cmakeshift_target_compile_settings(): Setting \"default-debugdevicecode\": Don't know how to enable device-code debug information for compiler \"${CMAKE_CUDA_COMPILER_ID}\"")
            endif()
        endif()

    elseif(SETTING STREQUAL "default-shared")
        # don't export symbols from shared object libraries unless explicitly annotated
        get_property(_ENABLED_LANGUAGES GLOBAL PROPERTY ENABLED_LANGUAGES)
        foreach(LANG IN ITEMS C CXX CUDA)
            if("${LANG}" IN_LIST _ENABLED_LANGUAGES)
                set_target_properties(${TARGET_NAME} PROPERTIES ${LANG}_VISIBILITY_PRESET hidden)
            endif()
        endforeach()

    elseif(SETTING STREQUAL "default-inlines-hidden")
        # don't export inline functions
        set_target_properties(${TARGET_NAME} PROPERTIES VISIBILITY_INLINES_HIDDEN TRUE)

    else()
        set(_SETTING_SET FALSE PARENT_SCOPE)
    endif()

endfunction()
