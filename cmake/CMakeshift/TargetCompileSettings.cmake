
# CMakeshift
# TargetCompileSettings.cmake
# Author: Moritz Beutel


if(DEFINED _CMAKESHIFT_KNOWN_SETTINGS)
    return() # prevent multiple inclusion
endif()


# Get the CMakeshift script include directory.
get_filename_component(CMAKESHIFT_SCRIPT_DIR ${CMAKE_CURRENT_LIST_DIR} DIRECTORY)


define_property(GLOBAL
    PROPERTY CMAKESHIFT_COMPILE_SETTINGS
    BRIEF_DOCS "Default compile settings"
    FULL_DOCS "Default compile settings")
define_property(DIRECTORY
    PROPERTY CMAKESHIFT_COMPILE_SETTINGS INHERITED
    BRIEF_DOCS "Directory compile settings"
    FULL_DOCS "Directory compile settings")

define_property(TARGET
    PROPERTY CMAKESHIFT_ARCHITECTURE_HAVE_FUSED_MULTIPLY_ADD
    BRIEF_DOCS "determines if target architecture supports fused multiply--add instructions"
    FULL_DOCS "determines if target architecture supports fused multiply--add instructions")
define_property(TARGET
    PROPERTY CMAKESHIFT_ARCHITECTURE_PREFER_AVX512
    BRIEF_DOCS "determines if target architecture prefers AVX-512 instructions"
    FULL_DOCS "determines if target architecture prefers AVX-512 instructions")

define_property(TARGET
    PROPERTY CMAKESHIFT_COMPILE_SETTINGS_
    BRIEF_DOCS "Compile settings used for target"
    FULL_DOCS "Compile settings used for target")
define_property(TARGET
    PROPERTY CMAKESHIFT_INTERFACE_COMPILE_SETTINGS_
    BRIEF_DOCS "Compile settings used for target interface"
    FULL_DOCS "Compile settings used for target interface")
define_property(TARGET
    PROPERTY CMAKESHIFT_RAW_COMPILE_SETTINGS_
    BRIEF_DOCS "compile settings used for target"
    FULL_DOCS "compile settings used for target")
define_property(TARGET
    PROPERTY CMAKESHIFT_INTERFACE_RAW_COMPILE_SETTINGS_
    BRIEF_DOCS "compile settings used for target interface"
    FULL_DOCS "compile settings used for target interface")
define_property(TARGET
    PROPERTY CMAKESHIFT_SUPPRESSED_COMPILE_SETTINGS_
    BRIEF_DOCS "compile settings to be suppressed for target"
    FULL_DOCS "compile settings to be suppressed for target")
define_property(TARGET
    PROPERTY CMAKESHIFT_SUPPRESSED_INTERFACE_COMPILE_SETTINGS_
    BRIEF_DOCS "compile settings to be suppressed for target interface"
    FULL_DOCS "compile settings to be suppressed for target interface")


set(CMAKESHIFT_COMPILE_SETTINGS "" CACHE STRING "Default compile settings to be applied to all targets with settings")


set(CMAKESHIFT_TRACE_OUTPUT OFF CACHE BOOL "Enable trace output for CMakeshift routines")
mark_as_advanced(CMAKESHIFT_TRACE_OUTPUT)


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


set(_CMAKESHIFT_KNOWN_CUMULATIVE_SETTINGS
    "default",
    "conformance",
    "debug",
    "security-checks",
    "runtime-checks",
    "sanitize"
)
set(_CMAKESHIFT_KNOWN_SETTINGS
    # architecture
    "cpu-architecture="
    "fp-model="
    "cuda-architecture="
    "cuda-gpu-code="

    # defaults
    "msvc-bigobj"
    "msvc-strip-comdat"
    "msvc-new-lambda-processor"
    "nvcc-relaxed-constexpr"
    "nvcc-extended-lambda"
    "flat-output-directory"
    "utf8-source"
    "win32-unicode"
    "hide-private-symbols"
    "hide-inlines"

    # debug
    "debug-justmycode"
    "debug-devicecode"

    # conformance
    "conformant-extensions"
    "msvc-conformant-volatile"
    "msvc-strict"
    "msvc-extern-constexpr"
    "msvc-cplusplus-macro"
    
    # diagnostics
    "pedantic-warnings"
    "paranoid-warnings"
    "fatal-errors"

    # security checks
    "protect-stack"
    "msvc-controlflowguard"

    # sanitize
    "sanitize-address"
    "sanitize-undefined"

    "debug-stdlib"
)

set(_CMAKESHIFT_CUMULATIVE_SETTING_default
    "msvc-bigobj"
    "msvc-strip-comdat"
    "msvc-new-lambda-processor"
    "nvcc-relaxed-constexpr"
    "nvcc-extended-lambda"
    "flat-output-directory"
    "utf8-source"
    "win32-unicode"
    "conformance"
    "debug-justmycode"
    "debug-devicecode"
    "hide-private-symbols"
    "hide-inlines"
    "pedantic-warnings"
    "paranoid-warnings")

set(_CMAKESHIFT_CUMULATIVE_SETTING_conformance
    "conformant-extensions"
    "msvc-conformant-volatile"
    "msvc-strict"
    "msvc-extern-constexpr"
    "msvc-cplusplus-macro")

set(_CMAKESHIFT_CUMULATIVE_SETTING_debug
    "debug-justmycode"
    "debug-devicecode")

set(_CMAKESHIFT_CUMULATIVE_SETTING_security-checks
    "protect-stack"
    "msvc-controlflowguard")

set(_CMAKESHIFT_CUMULATIVE_SETTING_runtime-checks
    "sanitize")

set(_CMAKESHIFT_CUMULATIVE_SETTING_sanitize
    "sanitize-address"
    "sanitize-undefined")




# Set known compile options for the target. 
#
#     cmakeshift_target_compile_settings(
#          <TARGET>|TARGETS <TARGET>...
#         PRIVATE|PUBLIC|INTERFACE <SETTING>...)
#
#
# Supported value groups for <SETTING>:
#
#     default                                   default options everyone can agree on
#     conformance                               configure compilers to be strict and conformant
#     debug                                     enable debugging aids
#     security-checks                           enable security checks as hardening measure
#     runtime-checks                            enable runtime checks
#     sanitize                                  enable sanitizers
#
#
# Supported values for <SETTING>:
#
#     msvc-bigobj                               enable /bigobj switch to permit more than 2^16 COMDAT sections per .obj file (can be useful in heavily templatized code)
#     msvc-strip-comdat                         remove unreferenced COMDATs to improve linker throughput
#     msvc-new-lambda-processor                 enable new lambda processor to improve diagnostics and fix some constexpr scoping issues
#     nvcc-relaxed-constexpr                    permit cross-domain calls during constexpr evaluation
#     nvcc-extended-lambda                      permit `__host__ __device__` annotation for lambda functions
#     flat-output-directory                     place executables and shared libraries in ${PROJECT_BINARY_DIR} unless target properties are set
#     utf8-source                               source files use UTF-8 encoding
#     win32-unicode                             UNICODE and _UNICODE are defined on Windows
#
#     conformant-extensions                     configure compilers to be ISO C++ conformant
#     msvc-conformant-volatile                  make `volatile` behave as specified by the language standard, as opposed to the quasi-atomic semantics VC++ implements by default
#     msvc-strict                               disable permissive mode
#     msvc-extern-constexpr                     enable `extern constexpr` support
#     msvc-cplusplus-macro                      enable updated `__cplusplus` macro value
#
#     debug-justmycode                          enable Just My Code for debugging convenience
#     debug-devicecode                          generate debug information for CUDA device code; disables optimizations in device code
#
#     hide-private-symbols                      don't export symbols from shared object libraries unless explicitly annotated (via __attribute__, __declspec, or .def file)
#     hide-inlines                              do not export inline functions (non-conformant but usually sane, and may speed up build)
#
#     pedantic-warnings                         highest sensible level for warnings and diagnostics
#     paranoid-warnings                         enable extra paranoid warnings
#     fatal-errors                              every error is fatal; stop after reporting first error
#
#     protect-stack                             enable stack protector
#     msvc-controlflowguard                     insert control flow guards
#
#     sanitize-address                          enable AddressSanitizer
#     sanitize-undefined                        enable UBSanitizer
#     debug-stdlib                              enable debug mode of standard library (precondition checks; debug iterators in Debug configuration, checked iterators in Release configuration)
# 
#     cpu-architecture=<arch>                   generate code for the given CPU architecture
#     fp-model=<model>                          configure the floating-point model
#     cuda-architecture=<arch>                  specify virtual or real CUDA architecture
#     cuda-gpu-code=<arch>                      specify real CUDA architecture
#
#
# Supported arguments for "cpu-architecture" setting:
#
#     default                   don't generate architecture-specific code
#     penryn                    generate code for Intel Core 2 Refresh "Penryn"
#     skylake                   generate code for Intel Core/Xeon "Skylake"
#     skylake-server            generate code for Intel Core/Xeon "Skylake Server"
#     skylake-server-avx512     generate code for Intel Core/Xeon "Skylake Server", prefer AVX-512 instructions
#     knl                       generate code for Intel Xeon Phi "Knights Landing"
#
# For the architectures "skylake-server-avx512" and "knl", the target property "CMAKESHIFT_ARCHITECTURE_PREFER_AVX512"
# is set to TRUE. To make the target property accessible in source code, evaluate the target property in a generator
# expression:
#
#     target_compile_definitions(<target>
#         PRIVATE
#             $<IF:$<GENEX_EVAL:$<TARGET_PROPERTY:CMAKESHIFT_ARCHITECTURE_PREFER_AVX512>>PREFER_AVX512>)
#
# For architectures which support fused multiply--add opcodes, the target property
# "CMAKESHIFT_ARCHITECTURE_HAVE_FUSED_MULTIPLY_ADD" is set to TRUE. To make the target property accessible in source
# code, evaluate the target property in a generator expression:
#
#     target_compile_definitions(<target>
#         PRIVATE
#             $<IF:$<GENEX_EVAL:$<TARGET_PROPERTY:CMAKESHIFT_ARCHITECTURE_HAVE_FUSED_MULTIPLY_ADD>>HAVE_FUSED_MULTIPLY_ADD>)
#
# A project-wide default for the "cpu-architecture" setting can be set with the option "CPU_ARCHITECTURE":
#
#     # Expose "CPU_ARCHITECTURE" as build configuration option
#     set(CPU_ARCHITECTURE "" CACHE STRING "Set CPU target architecture (default, penryn, skylake, skylake-server, skylake-server-avx512, knl)")
#
# The arguments for the "cuda-architecture" and "cuda-gpu-code" settings are simply passed through to
# the CUDA compiler. For a list of admissible values, please refer to NVIDIA's NVCC documentation:
#
#     https://docs.nvidia.com/cuda/cuda-compiler-driver-nvcc/index.html
#
# A project-wide default for the "cuda-architecture" and "cuda-gpu-code" settings can be set with the options
# "CUDA_ARCHITECTURE" and "CUDA_GPU_CODE":
#
#     # Expose "CUDA_ARCHITECTURE" and "CUDA_GPU_CODE" as build configuration options
#     set(CUDA_ARCHITECTURE "" CACHE STRING "Set CUDA target architecture (e.g. sm_61, compute_61)")
#     set(CUDA_GPU_CODE "" CACHE STRING "Set CUDA GPU code to generate (e.g. sm_61)")
#
#
# Supported arguments for "fp-model" setting:
#
#     default       compiler default setting (equivalent to "precise" for most compilers, "fast" for ICC)
#     strict        value safety, no contractions (e.g. fused multiply--add), precise FP exceptions
#     consistent    value safety, no contractions (e.g. fused multiply--add)
#     precise       value safety
#     fast          permit optimizations affecting value safety
#     fastest       permit aggressive optimizations affecting value safety
#
# Prefixing a sub-setting with "no-" suppresses it when the summary setting is used:
# 
#     # enables all options in "default" except for "debug-justmycode"
#     cmakeshift_target_compile_settings(foo
#         PRIVATE
#             default no-debug-justmycode)
# 
# Note that generator expressions are not supported for suppressed options.
# 
# When using "debug-stdlib", note that this setting may alter the object layout of STL containers.
# If your target exchanges STL container objects with other targets, those must also be compiled
# with "debug-stdlib", otherwise you may get silent data corruption at runtime. (This applies
# mostly to GCC and Clang; mismatching debug settings cause link-time errors for Visual C++.)
#
function(CMAKESHIFT_TARGET_COMPILE_SETTINGS)

    function(CMAKESHIFT_UPDATE_CACHE_VARIABLE_ VAR_NAME VALUE)
        get_property(HELP_STRING CACHE ${VAR_NAME} PROPERTY HELPSTRING)
        get_property(VAR_TYPE CACHE ${VAR_NAME} PROPERTY TYPE)
        set(${VAR_NAME} ${VALUE} CACHE ${VAR_TYPE} "${HELP_STRING}" FORCE)
    endfunction()

    function(CMAKESHIFT_GET_TARGET_PROPERTY_ VAR_NAME PROP_NAME)
        get_target_property(_VAR ${TARGET_NAME} ${PROP_NAME})
        if(NOT _VAR)
            set(_VAR "") # set to "" rather than "*-NOTFOUND" if target property doesn't exist
        endif()
        set(${VAR_NAME} "${_VAR}" PARENT_SCOPE)
    endfunction()

    function(CMAKESHIFT_TARGET_COMPILE_SETTING_ACCUMULATE_ TARGET_NAME SCOPE SETTING0)
        if(SCOPE STREQUAL INTERFACE)
            set(_INTERFACE "_INTERFACE")
        else()
            set(_INTERFACE "")
        endif()

        if(NOT SETTING0 MATCHES "^[Nn][Oo]-([_A-Za-z0-9-]+)=?$")
            return()
        endif()
        set(SETTING1 "${CMAKE_MATCH_1}")
        if(SETTING1 STREQUAL "")
            return()
        endif()
        string(TOLOWER "${SETTING1}" SETTING)

        # Is it a cumulative setting?
        if("${SETTING}" IN_LIST _CMAKESHIFT_KNOWN_CUMULATIVE_SETTINGS)
            # Recur and suppress all settings included in the cumulative setting.
            foreach(_SETTING IN LISTS _CMAKESHIFT_CUMULATIVE_SETTING_${SETTING})
                cmakeshift_target_compile_setting_accumulate_(${TARGET_NAME} ${SCOPE} "no-${_SETTING}")
                set(_SUPPRESSED${_INTERFACE}_SETTINGS "${_SUPPRESSED${_INTERFACE}_SETTINGS}" PARENT_SCOPE)
            endforeach()
            return()
        endif()

        # Is the setting known?
        if(NOT "${SETTING}" IN_LIST _CMAKESHIFT_KNOWN_SETTINGS AND NOT "${SETTING}=" IN_LIST _CMAKESHIFT_KNOWN_SETTINGS)
            message(SEND_ERROR "cmakeshift_target_compile_settings(): Unknown target setting \"${SETTING}\", don't know what to do with argument \"no-${SETTING}\"")
            return()
        endif()

        # Has it already been set in a previous call?
        if("${SETTING}" IN_LIST _RAW${_INTERFACE}_SETTINGS_0)
            message(WARNING "cmakeshift_target_compile_settings(): Cannot suppress setting \"${SETTING}\" because it was enabled in a previous call to cmakeshift_target_compile_settings().")
            return()
        endif()

        # Has it already been suppressed?
        if("${SETTING}" IN_LIST _SUPPRESSED${_INTERFACE}_SETTINGS)
            return()
        endif()

        if(CMAKESHIFT_TRACE_OUTPUT)
            if(SCOPE STREQUAL INTERFACE)
                message("[cmakeshift_target_compile_settings()] Target ${TARGET_NAME}: Suppressing interface setting \"${SETTING}\"")
            else()
                message("[cmakeshift_target_compile_settings()] Target ${TARGET_NAME}: Suppressing setting \"${SETTING}\"")
            endif()
        endif()
        list(APPEND _SUPPRESSED${_INTERFACE}_SETTINGS "${SETTING}")
        set(_SUPPRESSED${_INTERFACE}_SETTINGS "${_SUPPRESSED${_INTERFACE}_SETTINGS}" PARENT_SCOPE)
    endfunction()

    function(CMAKESHIFT_TARGET_COMPILE_SETTING_APPLY_ TARGET_NAME SCOPE SETTING0)
        if(SCOPE STREQUAL INTERFACE)
            set(_INTERFACE "_INTERFACE")
        else()
            set(_INTERFACE "")
        endif()

        if(SETTING0 MATCHES "^\\$<(.+):([_A-Za-z0-9-]+(=.*)?)>$")
            set(LB "$<${CMAKE_MATCH_1}:")
            set(SETTING1 "${CMAKE_MATCH_2}")
            set(RB ">")
        else()
            set(LB "")
            set(SETTING1 "${SETTING0}")
            set(RB "")
        endif()

        if(SETTING1 MATCHES "^([_A-Za-z0-9-]+)(=)(.*)$")
            set(SETTING2 "${CMAKE_MATCH_1}")
            set(VAL_EQ "${CMAKE_MATCH_2}")
            set(VAL "${CMAKE_MATCH_3}")
        else()
            set(SETTING2 "${SETTING1}")
            set(VAL_EQ "")
            set(VAL "")
        endif()

        if(SETTING2 STREQUAL "")
            return()
        endif()
        string(TOLOWER "${SETTING2}" SETTING)

        if(SETTING MATCHES "^no-[_A-Za-z0-9-]+$")
            if(NOT LB STREQUAL "")
                message(SEND_ERROR "cmakeshift_target_compile_settings(): \"${SETTING0}\": Cannot use generator expression with suppressed options")
            endif()
            return()
        endif()

        # Is it a cumulative setting?
        if("${SETTING}" IN_LIST _CMAKESHIFT_KNOWN_CUMULATIVE_SETTINGS)
            # Recur and set all settings included by the cumulative setting.
            foreach(_SETTING IN LISTS _CMAKESHIFT_CUMULATIVE_SETTING_${SETTING})
                cmakeshift_target_compile_setting_apply_(${TARGET_NAME} ${SCOPE} "${LB}${_SETTING}${RB}")
                set(_RAW_${_INTERFACE}_SETTINGS "${_RAW${_INTERFACE}_SETTINGS}" PARENT_SCOPE)
                set(_CURRENT${_INTERFACE}_SETTINGS "${_CURRENT${_INTERFACE}_SETTINGS}" PARENT_SCOPE)
            endforeach()
            return()
        endif()

        # Is the setting known?
        if(NOT "${SETTING}${VAL_EQ}" IN_LIST _CMAKESHIFT_KNOWN_SETTINGS)
            if(VAL_EQ STREQUAL "=" AND "${SETTING}" IN_LIST _CMAKESHIFT_KNOWN_SETTINGS)
                message(SEND_ERROR "cmakeshift_target_compile_settings(): Target setting \"${SETTING}\" cannot have value argument")
            elseif((NOT VAL_EQ STREQUAL "=") AND "${SETTING}${VAL_EQ}" IN_LIST _CMAKESHIFT_KNOWN_SETTINGS)
                message(SEND_ERROR "cmakeshift_target_compile_settings(): Target setting \"${SETTING}\" needs value argument (\"${SETTING}=<arg>\")")
            else()
                message(SEND_ERROR "cmakeshift_target_compile_settings(): Unknown target setting \"${SETTING}\"")
            endif()
            return()
        endif()

        # Has it already been set or suppressed?
        #if("${SETTING}" IN_LIST _RAW${_INTERFACE}_SETTINGS OR "${SETTING}" IN_LIST _SUPPRESSED${_INTERFACE}_SETTINGS OR "${LB}${SETTING}${VAL_EQ}${VAL}${RB}" IN_LIST _CURRENT${_INTERFACE}_SETTINGS)
        if("${SETTING}" IN_LIST _SUPPRESSED${_INTERFACE}_SETTINGS OR "${LB}${SETTING}${VAL_EQ}${VAL}${RB}" IN_LIST _CURRENT${_INTERFACE}_SETTINGS)
            #if(VAL_EQ STREQUAL "=")
            #    message(WARNING "cmakeshift_target_compile_settings(): Setting \"${SETTING}\" has already been set before; new setting\"${SETTING}=${VAL}\" is ignored")
            #endif()
            return()
        endif()

        set(_SETTING_SET TRUE)

        # local variables for use in settings: SETTING, HAVE_<LANG>, PASSTHROUGH, VAL, TARGET_NAME, SCOPE, LB, RB

        if(SETTING STREQUAL "msvc-bigobj")
            if(MSVC)
                # enable /bigobj switch to permit more than 2^16 COMDAT sections per .obj file (can be useful in heavily templatized code)
                target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}/bigobj${RB}")
            endif()

        elseif(SETTING STREQUAL "msvc-strip-comdat")
            if(MSVC)
                # remove unreferenced COMDATs to improve linker throughput
                target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}/Zc:inline${RB}") # available since pre-modern VS 2013 Update 2
            endif()

        elseif(SETTING STREQUAL "msvc-new-lambda-processor")
            if(MSVC AND CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 19.21) # available since VS 2019 16.1
                # enable new lambda processor to improve diagnostics and fix some constexpr scoping issues
                target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}/experimental:newLambdaProcessor${RB}")
            endif()

        elseif(SETTING STREQUAL "nvcc-relaxed-constexpr")
            if(HAVE_CUDA AND CMAKE_CUDA_COMPILER_ID MATCHES "NVIDIA") # NVCC
                # permit cross-domain calls during constexpr evaluation
                target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}$<$<COMPILE_LANGUAGE:CUDA>:--expt-relaxed-constexpr>${RB}")
            endif()

        elseif(SETTING STREQUAL "nvcc-extended-lambda")
            if(HAVE_CUDA AND CMAKE_CUDA_COMPILER_ID MATCHES "NVIDIA") # NVCC
                # permit `__host__ __device__` annotation for lambda functions
                target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}$<$<COMPILE_LANGUAGE:CUDA>:--expt-extended-lambda>${RB}")
            endif()

        elseif(SETTING STREQUAL "flat-output-directory")
            # place executables and shared libraries in ${PROJECT_BINARY_DIR} unless target properties are set
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

        elseif(SETTING STREQUAL "utf8-source")
            # source files use UTF-8 encoding
            if(MSVC)
                target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}/utf-8${RB}")
            endif()

        elseif(SETTING STREQUAL "win32-unicode")
            # UNICODE and _UNICODE are defined on Windows
            target_compile_definitions(${TARGET_NAME} ${SCOPE} "${LB}$<$<PLATFORM_ID:Windows>:UNICODE>${RB}" "${LB}$<$<PLATFORM_ID:Windows>:_UNICODE>${RB}")

        elseif(SETTING STREQUAL "conformant-extensions")
            # disable language extensions
            if(HAVE_C)
                set_target_properties(${TARGET_NAME} PROPERTIES C_EXTENSIONS OFF)
            endif()
            if(HAVE_CXX)
                set_target_properties(${TARGET_NAME} PROPERTIES CXX_EXTENSIONS OFF)
            endif()

        elseif(SETTING STREQUAL "msvc-conformant-volatile")
            if(MSVC)
                # make `volatile` behave as specified by the language standard, as opposed to the quasi-atomic semantics VC++ implements by default
                target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}/volatile:iso${RB}")
            endif()

        elseif(SETTING STREQUAL "msvc-strict")
            if(MSVC)
                # disable permissive mode
                if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 19.10)
                    target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}/permissive-${RB}") # available since VS 2017 15.0
                endif()
            endif()

        elseif(SETTING STREQUAL "msvc-extern-constexpr")
            if(MSVC)
                # enable `extern constexpr` support
                if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 19.13)
                    target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}/Zc:externConstexpr${RB}") # available since VS 2017 15.6
                endif()
            endif()

        elseif(SETTING STREQUAL "msvc-cplusplus-macro")
            if(MSVC)
                # enable updated `__cplusplus` macro value
                if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 19.14)
                    target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}/Zc:__cplusplus${RB}") # available since VS 2017 15.7
                endif()
            endif()

        elseif(SETTING STREQUAL "hide-private-symbols")
            # don't export symbols from shared object libraries unless explicitly annotated
            get_property(_ENABLED_LANGUAGES GLOBAL PROPERTY ENABLED_LANGUAGES)
            foreach(LANG IN ITEMS C CXX CUDA)
                if("${LANG}" IN_LIST _ENABLED_LANGUAGES)
                    set_target_properties(${TARGET_NAME} PROPERTIES ${LANG}_VISIBILITY_PRESET hidden)
                endif()
            endforeach()

        elseif(SETTING STREQUAL "hide-inlines")
            # don't export inline functions
            set_target_properties(${TARGET_NAME} PROPERTIES VISIBILITY_INLINES_HIDDEN TRUE)

        elseif(SETTING STREQUAL "debug-justmycode")
            if(MSVC)
                # enable Just My Code for debugging convenience
                # use target property VS_JUST_MY_CODE_DEBUGGING if possible
                if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.15)
                    set_target_properties(${TARGET_NAME} PROPERTIES VS_JUST_MY_CODE_DEBUGGING "${LB}$<$<CONFIG:Debug>:ON>${RB}")
                elseif(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 19.15)
                    target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}$<$<CONFIG:Debug>:${PASSTHROUGH}/JMC>${RB}") # available since VS 2017 15.8
                endif()
            endif()

        elseif(SETTING STREQUAL "debug-devicecode")
            # generate debug information for CUDA device code; disables optimizations in device code
            if(HAVE_CUDA)
                if(CMAKE_CUDA_COMPILER_ID MATCHES "NVIDIA")
                    target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}$<$<COMPILE_LANGUAGE:CUDA>:$<$<CONFIG:Debug>:--device-debug>>${RB}" "${LB}$<$<COMPILE_LANGUAGE:CUDA>:$<$<CONFIG:RelWithDebInfo>:--generate-line-info>>${RB}")

                else()
                    message(WARNING "cmakeshift_target_compile_settings(): Setting \"debug-devicecode\": Don't know how to enable device-code debug information for compiler \"${CMAKE_CUDA_COMPILER_ID}\"")
                endif()
            endif()

        elseif(SETTING STREQUAL "pedantic-warnings")
            # highest sensible level for warnings and diagnostics
            if(MSVC)
                # remove "/Wx" from CMAKE_CXX_FLAGS if present, as VC++ doesn't tolerate more than one "/Wx" flag
                if(CMAKE_CXX_FLAGS MATCHES "/W[0-4]")
                    string(REGEX REPLACE "/W[0-4]" " " CMAKE_CXX_FLAGS_NEW "${CMAKE_CXX_FLAGS}")
                    cmakeshift_update_cache_variable_(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS_NEW}")
                endif()
                if(CMAKE_CUDA_FLAGS MATCHES "/W[0-4]")
                    string(REGEX REPLACE "/W[0-4]" " " CMAKE_CUDA_FLAGS_NEW "${CMAKE_CUDA_FLAGS}") # TODO: is this done right, with the quoted string in CMAKE_CUDA_FLAGS?
                    cmakeshift_update_cache_variable_(CMAKE_CUDA_FLAGS "${CMAKE_CUDA_FLAGS_NEW}")
                endif()
                target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}/W4${RB}")

            elseif(CMAKE_C_COMPILER_ID MATCHES "GNU" OR CMAKE_CXX_COMPILER_ID MATCHES "GNU" OR CMAKE_CXX_COMPILER_ID MATCHES "Clang") # TODO: use $<CXX_COMPILER_ID:compiler_ids> and $<COMPILE_LANGUAGE:language> or $<COMPILE_LANG_AND_ID:language,compiler_ids> (CMake 3.15+) instead
                # We disable "-pedantic" for CUDA source files because the code generated by NVCC isn't "-pedantic"-clean. Specifically, it may generate preprocessor line statements as "#123", which 
                # makes GCC warn that the "style of line directive is a GCC extension". This was observed in conjunction with the "--generate-line-info" flag. We thus disable "-pedantic" for all CUDA
                # source files for the sake of consistency.
                target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}-Wall${RB}" "${LB}${PASSTHROUGH}-Wextra${RB}" "${LB}$<$<NOT:$<COMPILE_LANGUAGE:CUDA>>:${PASSTHROUGH}-pedantic>${RB}")

            elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
                # TODO: find out if the "-pedantic" issue for NVCC+GCC also exists for NVCC+Clang
                target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}-Wall${RB}" "${LB}${PASSTHROUGH}-Wextra${RB}" "${LB}${PASSTHROUGH}-Wpedantic${RB}" "${LB}${PASSTHROUGH}-Wdeprecated${RB}")

            elseif(CMAKE_C_COMPILER MATCHES "icc.*$" OR CMAKE_CXX_COMPILER MATCHES "icpc.*$") # Intel compiler
                target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}-Wall${RB}" "${LB}${PASSTHROUGH}-Wextra${RB}" "${LB}${PASSTHROUGH}-pedantic${RB}" "${LB}${PASSTHROUGH}-Wdeprecated${RB}")

            endif()

        elseif(SETTING STREQUAL "paranoid-warnings")
            # enable extra paranoid warnings
            if(MSVC)
                target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}/w44062${RB}") # enumerator 'identifier' in a switch of enum 'enumeration' is not handled
                target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}/w44242${RB}") # 'identifier': conversion from 'type1' to 'type2', possible loss of data
                target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}/w44254${RB}") # 'operator': conversion from 'type1' to 'type2', possible loss of data
                target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}/w44265${RB}") # 'class': class has virtual functions, but destructor is not virtual
                #target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}/w44365${RB}") # 'action': conversion from 'type_1' to 'type_2', signed/unsigned mismatch (cannot enable this one because it flags `container[signed_index]`)
            endif()

        elseif(SETTING STREQUAL "fatal-errors")
            # every error is fatal; stop after reporting first error
            if(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
                target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}-fmax-errors=1${RB}")

            elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
                target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}-ferror-limit=1${RB}")

            else()
                message(WARNING "cmakeshift_target_compile_settings(): Setting \"fatal-errors\": Don't know how make compiler \"${CMAKE_CXX_COMPILER_ID}\" stop after first error")
            endif()

        # TODO: add a setting for optimization reports, cf.
        # https://software.intel.com/en-us/cpp-compiler-developer-guide-and-reference-qopt-report-qopt-report
        # https://software.intel.com/en-us/cpp-compiler-developer-guide-and-reference-qopt-report-phase-qopt-report-phase
        # https://docs.microsoft.com/en-us/cpp/build/reference/qvec-report-auto-vectorizer-reporting-level
        # https://docs.microsoft.com/en-us/cpp/build/reference/qpar-report-auto-parallelizer-reporting-level
        # https://clang.llvm.org/docs/ClangCommandLineReference.html#diagnostic-flags
        # https://clang.llvm.org/docs/ClangCommandLineReference.html#cmdoption-clang-fsave-optimization-record
        # https://gcc.gnu.org/onlinedocs/gcc/Developer-Options.html ("-fopt-info")

        elseif(SETTING STREQUAL "protect-stack")
            elseif(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
                # enable stack protector
                target_compile_options(${TARGET_NAME} PRIVATE "${LB}${PASSTHROUGH}-fstack-protector${RB}")
            endif()

        elseif(SETTING STREQUAL "msvc-controlflowguard")
            if(MSVC)
                # insert control flow guards
                # Option "/ZI" (enable Edit & Continue) is incompatible with "/guard:cf", so suppress the latter if "/ZI" is present.
                set(FLAG_COND "0")
                if(CMAKE_CXX_FLAGS_DEBUG MATCHES "/ZI")
                    set(FLAG_COND "${FLAG_COND},$<CONFIG:Debug>")
                endif()
                if(CMAKE_CXX_FLAGS_RELWITHDEBINFO MATCHES "/ZI")
                    set(FLAG_COND "${FLAG_COND},$<CONFIG:RelWithDebInfo>")
                endif()
                target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}$<$<NOT:$<OR:${FLAG_COND}>>:/guard:cf>${RB}")
                target_link_libraries(${TARGET_NAME} ${SCOPE} "${LB}$<$<NOT:$<OR:${FLAG_COND}>>:-guard:cf>${RB}") # this flag also needs to be passed to the linker (CMake needs a leading '-' to recognize a flag here)
            endif()

        elseif(SETTING STREQUAL "sanitize-address")
            # enable AddressSanitizer
            if(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX OR (CMAKE_CXX_COMPILER_ID MATCHES "Clang"))
                target_compile_options(${TARGET_NAME} PRIVATE "${LB}${PASSTHROUGH}-fsanitize=address${RB}")
                target_link_libraries(${TARGET_NAME} PRIVATE "${LB}-fsanitize=address${RB}")
            
                if(HAVE_CUDA AND CMAKE_CUDA_COMPILER_ID MATCHES "NVIDIA")
                    get_target_property(_TARGET_TYPE ${TARGET_NAME} TYPE)
                    if (NOT target_type STREQUAL INTERFACE_LIBRARY)
                        # CUDA/NVCC has known incompatibilities with AddressSanitizer. We work around by setting "ASAN_OPTIONS=protect_shadow_gap=0" by providing a weakly
                        # linked `__asan_default_options()` function for any non-interface target.
                        if(HAVE_C)
                            set(_EXT ".c")
                        elseif(HAVE_CXX)
                            set(_EXT ".cpp")
                        else() # HAVE_CUDA
                            set(_EXT ".cu")
                        endif()
                        file(WRITE "${PROJECT_BINARY_DIR}/CMakeshift_AddressSanitizer_CUDA_workaround${_EXT}"
"#ifdef __cplusplus
extern \"C\"
#endif /* __cplusplus */
__attribute__((no_sanitize_address))
__attribute__((weak)) /* prevent any linking errors when linking multiple CUDA libraries, and permit the user to override it by providing his own `__asan_default_options()` implementation */
__attribute__((visibility(\"default\")))
char const* __asan_default_options(void)
{
        /* This option is used to make AddressSanitizer compatible with NVIDIA's CUDA runtime libraries and/or with NVCC, cf.
           https://devtalk.nvidia.com/default/topic/1037466/cuda-runtime-library-and-addresssanitizer-incompatibilty/ and
           https://github.com/google/sanitizers/issues/629 . */
    return \"protect_shadow_gap=0\";
}")
                        target_sources(${TARGET_NAME} PRIVATE "${LB}${PROJECT_BINARY_DIR}/CMakeshift_AddressSanitizer_CUDA_workaround${_EXT}${RB}")
                    endif()
                endif()

            else()
                message(WARNING "cmakeshift_target_compile_settings(): Setting \"sanitize-address\": Don't know how enable AddressSanitizer for compiler \"${CMAKE_CXX_COMPILER_ID}\"")
            endif()

        elseif(SETTING STREQUAL "sanitize-undefined")
            # enable UndefinedBehaviorSanitizer
            if(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
                target_compile_options(${TARGET_NAME} PRIVATE "${LB}${PASSTHROUGH}-fsanitize=undefined${RB}")
                target_link_libraries(${TARGET_NAME} PRIVATE "${LB}-fsanitize=undefined${RB}")

            elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
                # UBSan can cause linker errors in Clang 6 and 7, and it raises issues in libc++ debugging code
                if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS 8.0)
                    message(WARNING "cmakeshift_target_compile_settings(): Not enabling UBSan for target \"${TARGET_NAME}\" because it can cause linker errors in Clang 6 and 7.")
                    set(_SETTING_SET FALSE)
                elseif("debug-stdlib" IN_LIST _CURRENT${_INTERFACE}_SETTINGS)
                    message(WARNING "cmakeshift_target_compile_settings(): Not enabling UBSan for target \"${TARGET_NAME}\" because it is known to raise issues in libc++ debugging code.")
                    set(_SETTING_SET FALSE)
                else()
                    target_compile_options(${TARGET_NAME} PRIVATE "${LB}${PASSTHROUGH}-fsanitize=undefined${RB}")
                    target_link_libraries(${TARGET_NAME} PRIVATE "${LB}-fsanitize=undefined${RB}")
                endif()

            else()
                message(WARNING "cmakeshift_target_compile_settings(): Setting \"sanitize-undefined\": Don't know how enable UndefinedBehaviorSanitizer for compiler \"${CMAKE_CXX_COMPILER_ID}\"")
            endif()

        elseif(SETTING STREQUAL "debug-stdlib")
            if(MSVC)
                # enable checked iterators (not necessary in debug builds because these enable debug iterators by default, which are a superset of checked iterators)
                target_compile_definitions(${TARGET_NAME} PRIVATE "${LB}$<$<NOT:$<CONFIG:Debug>>:_ITERATOR_DEBUG_LEVEL=1>${RB}")

            elseif(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
                # enable libstdc++ debug mode
                target_compile_definitions(${TARGET_NAME} PRIVATE "${LB}$<$<CONFIG:Debug>:_GLIBCXX_DEBUG>${RB}")

            elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
                if("sanitize-undefined" IN_LIST _CURRENT${_INTERFACE}_SETTINGS)
                    message(WARNING "cmakeshift_target_compile_settings(): Setting \"debug-stdlib\": Not enabling standard library debug mode for target \"${TARGET}\" because it uses UBSan, which is known to raise issues in libc++ debugging code.")
                    set(_SETTING_SET FALSE)
                else()
                    # enable libc++ debug mode
                    target_compile_definitions(${TARGET_NAME} PRIVATE "${LB}$<IF:$<CONFIG:Debug>,_LIBCPP_DEBUG=1,_LIBCPP_DEBUG=0>${RB}")
                endif()

            else()
                message(WARNING "cmakeshift_target_compile_settings(): Setting \"debug-stdlib\": Don't know how to enable library debug mode for compiler \"${CMAKE_CXX_COMPILER_ID}\"")
            endif()

        elseif(SETTING STREQUAL "cpu-architecture")

            string(TOLOWER "${VAL}" ARCH)

            if(NOT ARCH STREQUAL "default" AND NOT ARCH STREQUAL "")

                # FMA3 is available starting with Haswell, which is also the first to support AVX2.
                if(ARCH STREQUAL "skylake" OR ARCH STREQUAL "skylake-server" OR ARCH STREQUAL "skylake-server-avx512" OR ARCH STREQUAL "knl")
                    set_target_properties(${TARGET_NAME}
                        PROPERTIES CMAKESHIFT_ARCHITECTURE_HAVE_FUSED_MULTIPLY_ADD ${LB}TRUE${RB})
                    target_compile_definitions(${TARGET_NAME} ${SCOPE} "${LB}HAVE_FUSED_MULTIPLY_ADD=1${RB}") # TODO: remove
                endif()
                if(ARCH STREQUAL "skylake-server-avx512" OR ARCH STREQUAL "knl")
                    set_target_properties(${TARGET_NAME}
                        PROPERTIES CMAKESHIFT_ARCHITECTURE_PREFER_AVX512 ${LB}TRUE${RB})
                    target_compile_definitions(${TARGET_NAME} ${SCOPE} "${LB}PREFER_AVX512=1${RB}") # TODO: remove
                endif()

                if(MSVC)
                    if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 19.10)
                        set(AVX512ARG "/arch:AVX512") # available since VS 2017
                    else()
                        set(AVX512ARG "/arch:AVX2")
                    endif()
                
                    if(ARCH STREQUAL "knl")
                        target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}/favor:ATOM${RB}")
                    else()
                        target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}/favor:INTEL64${RB}")
                    endif()
                
                    if(ARCH STREQUAL "penryn")
                    elseif(ARCH STREQUAL "skylake")
                        target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}/arch:AVX2${RB}")
                    elseif(ARCH STREQUAL "skylake-server" OR ARCH STREQUAL "skylake-server-avx512" OR ARCH STREQUAL "knl")
                        target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}${AVX512ARG}${RB}")
                    else()
                        set(_SETTING_SET FALSE PARENT_SCOPE)
                    endif()
                elseif(CMAKE_C_COMPILER MATCHES "icc.*$" OR CMAKE_CXX_COMPILER MATCHES "icpc.*$") # Intel compiler
                    if(WIN32)
                        set(ARCHARG "/arch:")
                        set(ARCHARG2 "/arch:")
                        set(QARG "/Q")
                        set(XARG "/Qx")
                        set(ASGN ":")
                    else()
                        set(ARCHARG "-m")
                        set(ARCHARG2 "-march=")
                        set(QARG "-q")
                        set(XARG "-x")
                        set(ASGN "=")
                    endif()
                    if(ARCH STREQUAL "penryn")
                        target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}${ARCHARG}sse4.1${RB}" "${LB}${PASSTHROUGH}${XARG}sse4.1${RB}")
                    elseif(ARCH STREQUAL "skylake")
                        target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}${ARCHARG2}core-avx2${RB}" "${LB}${PASSTHROUGH}${XARG}core-avx2${RB}")
                    elseif(ARCH STREQUAL "skylake-server")
                        target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}${ARCHARG2}core-avx2${RB}" "${LB}${PASSTHROUGH}${XARG}core-avx512${RB}")
                    elseif(ARCH STREQUAL "skylake-server-avx512")
                        target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}${ARCHARG2}core-avx2${RB}" "${LB}${PASSTHROUGH}${XARG}core-avx512${RB}" "${LB}${PASSTHROUGH}${QARG}opt-zmm-usage${ASGN}high${RB}")
                    elseif(ARCH STREQUAL "knl")
                        target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}${ARCHARG2}core-avx2${RB}" "${LB}${PASSTHROUGH}${XARG}mic-avx512${RB}")
                    else()
                        set(_SETTING_SET FALSE PARENT_SCOPE)
                    endif()
                elseif(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
                    if(ARCH STREQUAL "penryn")
                        target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}-march=core2${RB}" "${LB}${PASSTHROUGH}-msse4.1${RB}")
                    elseif(ARCH STREQUAL "skylake")
                        target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}-march=skylake${RB}")
                    elseif(ARCH STREQUAL "skylake-server")
                        target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}-march=skylake-avx512${RB}")
                    elseif(ARCH STREQUAL "skylake-server-avx512")
                        target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}-march=skylake-avx512${RB}" "${LB}${PASSTHROUGH}-mprefer-vector-width=512${RB}")
                    elseif(ARCH STREQUAL "knl")
                        target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}-march=knl${RB}" "${LB}${PASSTHROUGH}-mprefer-vector-width=512${RB}")
                    else()
                        set(_SETTING_SET FALSE PARENT_SCOPE)
                    endif()
                elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
                    if(ARCH STREQUAL "penryn")
                        target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}-march=penryn${RB}")
                    elseif(ARCH STREQUAL "skylake")
                        target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}-march=skylake${RB}")
                    elseif(ARCH STREQUAL "skylake-server")
                        target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}-march=skylake-avx512${RB}")
                    elseif(ARCH STREQUAL "skylake-server-avx512")
                        target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}-march=skylake-avx512${RB}" "${LB}${PASSTHROUGH}-mprefer-vector-width=512${RB}")
                    elseif(ARCH STREQUAL "knl")
                        target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}-march=knl${RB}" "${LB}${PASSTHROUGH}-mprefer-vector-width=512${RB}")
                    else()
                        set(_SETTING_SET FALSE PARENT_SCOPE)
                    endif()

                else()
                    message(WARNING "cmakeshift_target_compile_settings(): Setting \"cpu-architecture=<arch>\": Don't know how to set target architecture for compiler \"${CMAKE_CXX_COMPILER_ID}\"")
                endif()

                if(NOT _SETTING_SET)
                    message(SEND_ERROR "cmakeshift_target_compile_settings(): Setting \"cpu-architecture=<arch>\": Unknown CPU architecture \"${ARCH}\"")
                endif()

            endif()

        elseif(SETTING STREQUAL "fp-model")

            string(TOLOWER "${VAL}" MODEL)

            if(NOT MODEL STREQUAL "" AND NOT MODEL STREQUAL "default")

                if(HAVE_CUDA)
                    if(CMAKE_CUDA_COMPILER_ID MATCHES "NVIDIA")
                        if(MODEL STREQUAL "strict" OR MODEL STREQUAL "consistent")
                            target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}$<$<COMPILE_LANGUAGE:CUDA>:--fmad=false>${RB}") # do not fuse multiplications and additions
                        elseif(MODEL STREQUAL "precise")
                            # default behavior; nothing to do
                        elseif(MODEL STREQUAL "fast")
                            target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}$<$<COMPILE_LANGUAGE:CUDA>:--ftz=true>${RB}" "${LB}$<$<COMPILE_LANGUAGE:CUDA>:--prec-div=false${RB}" "${LB}$<$<COMPILE_LANGUAGE:CUDA>:--prec-sqrt=false>${RB}")
                        elseif(MODEL STREQUAL "fastest")
                            target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}$<$<COMPILE_LANGUAGE:CUDA>:--use_fast_math>${RB}") # implies everything in "fast" above
                        else()
                            set(_SETTING_SET FALSE PARENT_SCOPE)
                        endif()
                    
                    else()
                        message(FATAL_ERROR "cmakeshift_target_compile_settings(): Unknown CUDA compiler: CMAKE_CUDA_COMPILER_ID=${CMAKE_CUDA_COMPILER_ID}")
                    endif()
                endif()

                if(MSVC)
                    if(MODEL STREQUAL "strict" OR MODEL STREQUAL "consistent")
                        target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}/fp:strict${RB}")
                    elseif(MODEL STREQUAL "precise")
                        target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}/fp:precise${RB}")
                    elseif(MODEL STREQUAL "fast" OR MODEL STREQUAL "fastest")
                        target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}/fp:fast${RB}")
                    else()
                        set(_SETTING_SET FALSE PARENT_SCOPE)
                    endif()
                elseif(CMAKE_C_COMPILER MATCHES "icc.*$" OR CMAKE_CXX_COMPILER MATCHES "icpc.*$") # Intel compiler
                    if(MODEL STREQUAL "strict" OR MODEL STREQUAL "consistent" OR MODEL STREQUAL "precise" OR MODEL STREQUAL "fast")
                        set(MODELARG ${MODEL})
                    elseif(MODEL STREQUAL "fastest")
                        set(MODELARG "fast=2")
                    else()
                        set(_SETTING_SET FALSE PARENT_SCOPE)
                    endif()
                    if(_SETTING_SET)
                        if(WIN32)
                            target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}/fp:${MODELARG}${RB}")
                        else()
                            target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}-fp-model${RB} ${LB}${MODELARG}${RB}") # TODO: does this work, or do we need two separate arguments?
                        endif()
                    endif()
                elseif(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
                    if(MODEL STREQUAL "strict" OR MODEL STREQUAL "consistent")
                        target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}-ffp-contract=off${RB}")
                    elseif(MODEL STREQUAL "precise")
                        # default behavior; nothing to do
                    elseif(MODEL STREQUAL "fast")
                        target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}-funsafe-math-optimizations${RB}")
                    elseif(MODEL STREQUAL "fastest")
                        target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}-ffast-math${RB}")
                    else()
                        set(_SETTING_SET FALSE PARENT_SCOPE)
                    endif()
                elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
                    if(MODEL STREQUAL "strict" OR MODEL STREQUAL "consistent" OR MODEL STREQUAL "precise")
                        # default behavior; nothing to do
                    elseif(MODEL STREQUAL "fast" OR MODEL STREQUAL "fastest")
                        target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}-ffast-math${RB}")
                    else()
                        set(_SETTING_SET FALSE PARENT_SCOPE)
                    endif()

                else()
                    message(WARNING "cmakeshift_target_compile_settings(): Setting \"fp-model=<model>\": Don't know how to set floating-point model for compiler \"${CMAKE_CXX_COMPILER_ID}\"")
                endif()

                if(NOT _SETTING_SET)
                    message(SEND_ERROR "cmakeshift_target_compile_settings(): Setting \"fp-model=<model>\": Unknown floating-point model \"${MODEL}\"")
                endif()

            endif()
        
        elseif(SETTING STREQUAL "cuda-architecture")

            string(TOLOWER "${VAL}" ARCH)

            if(HAVE_CUDA AND NOT ARCH STREQUAL "" AND NOT ARCH STREQUAL "default")
                if(CMAKE_CUDA_COMPILER_ID MATCHES "NVIDIA")
                    target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}$<$<COMPILE_LANGUAGE:CUDA>:--gpu-architecture=${ARCH}>${RB}")
                else()
                    message(WARNING "cmakeshift_target_compile_settings(): Setting \"cuda-architecture=<arch>\": Don't know how to set CUDA architecture for compiler \"${CMAKE_CUDA_COMPILER_ID}\"")
                endif()
            endif()
        
        elseif(SETTING STREQUAL "cuda-gpu-code")

            string(TOLOWER "${VAL}" GPUCODE)

            if(HAVE_CUDA AND NOT GPUCODE STREQUAL "" AND NOT GPUCODE STREQUAL "default")
                if(CMAKE_CUDA_COMPILER_ID MATCHES "NVIDIA")
                    target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}$<$<COMPILE_LANGUAGE:CUDA>:--gpu-code=${GPUCODE}>${RB}")
                else()
                    message(WARNING "cmakeshift_target_compile_settings(): Setting \"cuda-gpu-code=<arch>\": Don't know how to set CUDA GPU code level for compiler \"${CMAKE_CUDA_COMPILER_ID}\"")
                endif()
            endif()

        else()
            set(_SETTING_SET FALSE PARENT_SCOPE)
        endif()

        if(_SETTING_SET)
            if(CMAKESHIFT_TRACE_OUTPUT)
                if(SCOPE STREQUAL INTERFACE)
                    message("[cmakeshift_target_compile_settings()] Target ${TARGET_NAME}: Applying interface setting \"${LB}${SETTING}${RB}\"")
                else()
                    message("[cmakeshift_target_compile_settings()] Target ${TARGET_NAME}: Applying setting \"${LB}${SETTING}${RB}\"")
                endif()
            endif()
            list(APPEND _RAW${_INTERFACE}_SETTINGS "${SETTING}" PARENT_SCOPE)
            list(APPEND _CURRENT${_INTERFACE}_SETTINGS "${LB}${SETTING}${RB}" PARENT_SCOPE)
        endif()
    endfunction()

    function(CMAKESHIFT_TARGET_COMPILE_SETTINGS_IMPL TARGET_NAME)
    
        set(_TARGET_FIRST_TOUCH FALSE)

        get_target_property(_CURRENT_SETTINGS ${TARGET_NAME} CMAKESHIFT_COMPILE_SETTINGS_)
        if(NOT _CURRENT_SETTINGS)
            set(_TARGET_FIRST_TOUCH TRUE) # no settings have been set on the target before; remember this so we can apply global settings
            set(_CURRENT_SETTINGS "") # set to "NOTFOUND" if target property doesn't exist
        endif()
        cmakeshift_get_target_property_(_CURRENT_INTERFACE_SETTINGS CMAKESHIFT_INTERFACE_COMPILE_SETTINGS_)
        cmakeshift_get_target_property_(_RAW_SETTINGS CMAKESHIFT_RAW_COMPILE_SETTINGS_)
        cmakeshift_get_target_property_(_RAW_INTERFACE_SETTINGS CMAKESHIFT_INTERFACE_RAW_COMPILE_SETTINGS_)
        cmakeshift_get_target_property_(_SUPPRESSED_SETTINGS CMAKESHIFT_SUPPRESSED_COMPILE_SETTINGS_)
        cmakeshift_get_target_property_(_SUPPRESSED_INTERFACE_SETTINGS CMAKESHIFT_SUPPRESSED_INTERFACE_COMPILE_SETTINGS_)
        if(CMAKESHIFT_TRACE_OUTPUT)
            message("[cmakeshift_target_compile_settings()] Target ${TARGET_NAME}: Previously applied settings: \"${_CURRENT_SETTINGS}\"")
            message("[cmakeshift_target_compile_settings()] Target ${TARGET_NAME}: Previously applied interface settings: \"${_CURRENT_INTERFACE_SETTINGS}\"")
            message("[cmakeshift_target_compile_settings()] Target ${TARGET_NAME}: Previously suppressed settings: \"${_SUPPRESSED_SETTINGS}\"")
            message("[cmakeshift_target_compile_settings()] Target ${TARGET_NAME}: Previously suppressed interface settings \"${_SUPPRESSED_INTERFACE_SETTINGS}\"")
        endif()

        set(_RAW_SETTINGS_0 "${_RAW_SETTINGS}")
        set(_RAW_INTERFACE_SETTINGS_0 "${_RAW_INTERFACE_SETTINGS}")

        # Apply global settings if this is the first call to `cmakeshift_target_compile_settings()` for this target.
        if(_TARGET_FIRST_TOUCH)
            get_target_property(_TARGET_TYPE ${TARGET_NAME} TYPE)
            # Interface library targets cannot have private settings; skip any global defaults.
            if (NOT target_type STREQUAL INTERFACE_LIBRARY)
                set(SCOPE_PRIVATE "${CMAKESHIFT_COMPILE_SETTINGS}" "${SCOPE_PRIVATE}")
                
                # Look for build option CPU_ARCHITECTURE.
                if(DEFINED CPU_ARCHITECTURE AND NOT CPU_ARCHITECTURE STREQUAL "")
                    set(SCOPE_PRIVATE "cpu-architecture=${CPU_ARCHITECTURE}" "${SCOPE_PRIVATE}")
                endif()

                # Look for build options CUDA_ARCHITECTURE and CUDA_GPU_CODE.
                if(HAVE_CUDA)
                    if(DEFINED CUDA_ARCHITECTURE AND NOT CUDA_ARCHITECTURE STREQUAL "")
                        set(SCOPE_PRIVATE "cuda-architecture=${CUDA_ARCHITECTURE}" "${SCOPE_PRIVATE}")
                    endif()
                    if(DEFINED CUDA_GPU_CODE AND NOT CUDA_GPU_CODE STREQUAL "")
                        set(SCOPE_PRIVATE "cuda-gpu-code=${CUDA_GPU_CODE}" "${SCOPE_PRIVATE}")
                    endif()
                endif()
            endif()
        endif()

        foreach(arg IN LISTS SCOPE_PRIVATE SCOPE_PUBLIC)
            cmakeshift_target_compile_setting_accumulate_(${TARGET_NAME} PRIVATE "${arg}")
        endforeach()
        foreach(arg IN LISTS SCOPE_INTERFACE SCOPE_PUBLIC)
            cmakeshift_target_compile_setting_accumulate_(${TARGET_NAME} INTERFACE "${arg}")
        endforeach()

        foreach(arg IN LISTS SCOPE_PRIVATE SCOPE_PUBLIC)
            cmakeshift_target_compile_setting_apply_(${TARGET_NAME} PRIVATE "${arg}")
        endforeach()
        foreach(arg IN LISTS SCOPE_INTERFACE SCOPE_PUBLIC)
            cmakeshift_target_compile_setting_apply_(${TARGET_NAME} INTERFACE "${arg}")
        endforeach()

        set_target_properties(${TARGET_NAME}
            PROPERTIES
                CMAKESHIFT_COMPILE_SETTINGS_ "${_CURRENT_SETTINGS}"
                CMAKESHIFT_INTERFACE_COMPILE_SETTINGS_ "${_CURRENT_INTERFACE_SETTINGS}"
                CMAKESHIFT_RAW_COMPILE_SETTINGS_ "${_RAW_SETTINGS}"
                CMAKESHIFT_RAW_INTERFACE_COMPILE_SETTINGS_ "${_RAW_INTERFACE_SETTINGS}"
                CMAKESHIFT_SUPPRESSED_COMPILE_SETTINGS_ "${_SUPPRESSED_SETTINGS}"
                CMAKESHIFT_SUPPRESSED_INTERFACE_COMPILE_SETTINGS_ "${_SUPPRESSED_INTERFACE_SETTINGS}")
    endfunction()

    # Detect enabled languages and set flags.
    set(HAVE_C FALSE)
    set(HAVE_CXX FALSE)
    set(HAVE_CUDA FALSE)
    get_property(_ENABLED_LANGUAGES GLOBAL PROPERTY ENABLED_LANGUAGES)
    if(C IN_LIST _ENABLED_LANGUAGES)
        set(HAVE_C TRUE)
    endif()
    if(CXX IN_LIST _ENABLED_LANGUAGES)
        set(HAVE_CXX TRUE)
    endif()
    if(CUDA IN_LIST _ENABLED_LANGUAGES)
        set(HAVE_CUDA TRUE)
    endif()

    # Set variable PASSTHROUGH to support the NVCC compiler driver.
    set(PASSTHROUGH "")
    if(HAVE_CUDA)
        if(CMAKE_CUDA_COMPILER_ID MATCHES "NVIDIA")
            set(PASSTHROUGH "$<$<COMPILE_LANGUAGE:CUDA>:-Xcompiler=>")
        else()
            message(FATAL_ERROR "cmakeshift_target_compile_settings(): Unknown CUDA compiler: CMAKE_CUDA_COMPILER_ID=${CMAKE_CUDA_COMPILER_ID}")
        endif()
    endif()

    set(options "")
    set(oneValueArgs "")
    set(multiValueArgs PRIVATE INTERFACE PUBLIC TARGETS)
    cmake_parse_arguments(PARSE_ARGV 0 "SCOPE" "${options}" "${oneValueArgs}" "${multiValueArgs}")
    if(SCOPE_UNPARSED_ARGUMENTS)
        list(LENGTH SCOPE_UNPARSED_ARGUMENTS _NUM_UNPARSED_ARGUMENTS)
        if(_NUM_UNPARSED_ARGUMENTS GREATER_EQUAL 1)
            if(SCOPE_TARGETS)
                message(SEND_ERROR "cmakeshift_target_compile_settings(): Specify either a single target as first parameter or multiple targets with the TARGETS argument, but not both")
            else()
                list(GET SCOPE_UNPARSED_ARGUMENTS 0 SCOPE_TARGETS)
                list(REMOVE_AT SCOPE_UNPARSED_ARGUMENTS 0)
            endif()
            if(_NUM_UNPARSED_ARGUMENTS GREATER 1)
                message(SEND_ERROR "cmakeshift_target_compile_settings(): Invalid argument keywords \"${SCOPE_UNPARSED_ARGUMENTS}\"; expected TARGETS, PRIVATE, INTERFACE, or PUBLIC")
            endif()
        endif()
    endif()
    if(NOT SCOPE_TARGETS)
        message(SEND_ERROR "cmakeshift_target_compile_settings(): No target given; specify either a single target as first parameter or multiple targets with the TARGETS argument")
    endif()
    
    foreach(TARGET_NAME IN LISTS SCOPE_TARGETS)
        CMAKESHIFT_TARGET_COMPILE_SETTINGS_IMPL("${TARGET_NAME}")
    endforeach()

endfunction()
