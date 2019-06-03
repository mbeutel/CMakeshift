
# CMakeshift
# detail/Settings-Default.cmake
# Author: Moritz Beutel



list(APPEND _CMAKESHIFT_KNOWN_CUMULATIVE_SETTINGS
    "default")

list(APPEND _CMAKESHIFT_KNOWN_SETTINGS
    "default-base"
    "default-output-directory"
    "default-utf8-source"
    "default-windows-unicode"
    "default-triplet"
    "default-conformance"
    "default-debugjustmycode"
    "default-debugdevicecode"
    "default-shared"
    "default-inlines-hidden")


if(_VCPKG_ROOT_DIR AND VCPKG_TARGET_TRIPLET)
    include("${_VCPKG_ROOT_DIR}/triplets/${VCPKG_TARGET_TRIPLET}.cmake")

    # set default library linkage according to selected triplet
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        set(BUILD_SHARED_LIBS ON CACHE BOOL "Build shared library")
    elseif(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        set(BUILD_SHARED_LIBS OFF CACHE BOOL "Build shared library")
    else()
        message(FATAL_ERROR "Invalid setting for VCPKG_LIBRARY_LINKAGE: \"${VCPKG_LIBRARY_LINKAGE}\". It must be \"static\" or \"dynamic\"")
    endif()
endif()


function(_CMAKESHIFT_SETTINGS_DEFAULT)

	# variables available from calling scope: SETTING, HAVE_CUDA, PASSTHROUGH, VAL, TARGET_NAME, SCOPE, LB, RB

    if(SETTING STREQUAL "default-base")
        # default options everyone can agree on
        if(MSVC)
            # enable /bigobj switch to permit more than 2^16 COMDAT sections per .obj file (can be useful in heavily templatized code)
            target_compile_options(${TARGET_NAME} ${SCOPE} ${PASSTHROUGH} "${LB}/bigobj${RB}")

            # remove unreferenced COMDATs to improve linker throughput
            target_compile_options(${TARGET_NAME} ${SCOPE} ${PASSTHROUGH} "${LB}/Zc:inline${RB}") # available since pre-modern VS 2013 Update 2
        endif()

        if(HAVE_CUDA AND CMAKE_CUDA_COMPILER_ID MATCHES "NVIDIA") # NVCC
            # permit cross-domain calls during constexpr evaluation
            target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}$<$<COMPILE_LANGUAGE:CUDA>:--expt-relaxed-constexpr>${RB}")

            # permit `__host__ __device__` annotation for lambda functions
            target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}$<$<COMPILE_LANGUAGE:CUDA>:--expt-extended-lambda>${RB}")
        endif()

    elseif(SETTING STREQUAL "default-output-directory")
        # place binaries in ${PROJECT_BINARY_DIR}
        get_target_property(_TARGET_TYPE ${TARGET_NAME} TYPE)
        if(_TARGET_TYPE STREQUAL SHARED_LIBRARY OR _TARGET_TYPE STREQUAL MODULE_LIBRARY OR _TARGET_TYPE STREQUAL EXECUTABLE)
            set_target_properties(${TARGET_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}" LIBRARY_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}")
        endif()

    elseif(SETTING STREQUAL "default-utf8-source")
        # source files use UTF-8 encoding
        if(MSVC)
            target_compile_options(${TARGET_NAME} ${SCOPE} ${PASSTHROUGH} "${LB}/utf-8${RB}")
        endif()

    elseif(SETTING STREQUAL "default-windows-unicode")
        # UNICODE and _UNICODE are defined on Windows
        target_compile_definitions(${TARGET_NAME} ${SCOPE} "${LB}$<$<PLATFORM_ID:Windows>:UNICODE>${RB}" "${LB}$<$<PLATFORM_ID:Windows>:_UNICODE>${RB}")

    elseif(SETTING STREQUAL "default-triplet")
        # heed linking options of selected Vcpkg triplet
        if(MSVC AND VCPKG_CRT_LINKAGE)
            get_target_property(_TARGET_TYPE ${TARGET_NAME} TYPE)
            if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
                set(_CRT_FLAG "D")
            elseif(VCPKG_CRT_LINKAGE STREQUAL "static")
                if(${_TARGET_TYPE} STREQUAL SHARED_LIBRARY)
                    message(FATAL_ERROR "When building a shared library, VCPKG_CRT_LINKAGE must be set to \"dynamic\". Current setting is \"${VCPKG_CRT_LINKAGE}\"")
                endif()
                set(_CRT_FLAG "T")
            else()
                message(FATAL_ERROR "Invalid setting for VCPKG_CRT_LINKAGE: \"${VCPKG_CRT_LINKAGE}\". It must be \"static\" or \"dynamic\"")
            endif()

            # replace dynamic library linking flags with the desired option
            if(CMAKE_CXX_FLAGS_DEBUG MATCHES "/M(D|T)d")
                string(REGEX REPLACE "/M(D|T)d" "/M${_CRT_FLAG}d" CMAKE_CXX_FLAGS_DEBUG_NEW "${CMAKE_CXX_FLAGS_DEBUG}")
                cmakeshift_update_cache_variable_(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG_NEW}")
            endif()
            if(CMAKE_CXX_FLAGS_RELEASE MATCHES "/M(D|T)")
                string(REGEX REPLACE "/M(D|T)" "/M${_CRT_FLAG}" CMAKE_CXX_FLAGS_RELEASE_NEW "${CMAKE_CXX_FLAGS_RELEASE}")
                cmakeshift_update_cache_variable_(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE_NEW}")
            endif()
        endif()

    elseif(SETTING STREQUAL "default-conformance")
        # configure compilers to be ISO C++ conformant

        # disable language extensions
        set_target_properties(${TARGET_NAME} PROPERTIES CXX_EXTENSIONS OFF)

        if(MSVC)
            # make `volatile` behave as specified by the language standard, as opposed to the quasi-atomic semantics VC++ implements by default
            target_compile_options(${TARGET_NAME} ${SCOPE} ${PASSTHROUGH} "${LB}/volatile:iso${RB}")

            # enable permissive mode (prefer already rejuvenated parts of compiler for better conformance)
            if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 19.10)
                target_compile_options(${TARGET_NAME} ${SCOPE} ${PASSTHROUGH} "${LB}/permissive-${RB}") # available since VS 2017 15.0
            endif()

            # enable "extern constexpr" support
            if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 19.13)
                target_compile_options(${TARGET_NAME} ${SCOPE} ${PASSTHROUGH} "${LB}/Zc:externConstexpr${RB}") # available since VS 2017 15.6
            endif()

            # enable updated __cplusplus macro value
            if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 19.14)
                target_compile_options(${TARGET_NAME} ${SCOPE} ${PASSTHROUGH} "${LB}/Zc:__cplusplus${RB}") # available since VS 2017 15.7
            endif()
        endif()

    elseif(SETTING STREQUAL "default-debugjustmycode")
        # enable debugging aids
        if(MSVC)
            # enable Just My Code for debugging convenience
            if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 19.15)
                target_compile_options(${TARGET_NAME} ${SCOPE} ${PASSTHROUGH} "${LB}$<$<CONFIG:Debug>:/JMC>${RB}") # available since VS 2017 15.8
            endif()
        endif()

    elseif(SETTING STREQUAL "default-debugdevicecode")
        # enable device code debugging
        if(HAVE_CUDA)
			if(CMAKE_CUDA_COMPILER_ID MATCHES "NVIDIA")
				target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}$<$<COMPILE_LANGUAGE:CUDA>:$<$<CONFIG:Debug>:-G>>${RB}" "${LB}$<$<COMPILE_LANGUAGE:CUDA>:$<$<CONFIG:RelWithDebInfo>:--generate-line-info>>${RB}")
				target_compile_definitions(${TARGET_NAME} ${SCOPE} "${LB}$<$<NOT:$<CONFIG:Debug>>:NDEBUG>${RB}")
			else()
				message(FATAL_ERROR "cmakeshift_target_compile_settings(): Unknown CUDA compiler: CMAKE_CUDA_COMPILER_ID=${CMAKE_CUDA_COMPILER_ID}")
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
