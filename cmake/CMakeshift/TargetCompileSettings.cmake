
# CMakeshift
# TargetCompileSettings.cmake
# Author: Moritz Beutel


if(DEFINED _CMAKESHIFT_KNOWN_SETTINGS)
    return() # prevent multiple inclusion
endif()


# Get the CMakeshift script include directory.
get_filename_component(CMAKESHIFT_SCRIPT_DIR ${CMAKE_CURRENT_LIST_DIR} DIRECTORY)


define_property(TARGET
    PROPERTY CMAKESHIFT_COMPILE_SETTINGS
    BRIEF_DOCS "compile settings used for target"
    FULL_DOCS "compile settings used for target")
define_property(TARGET
    PROPERTY CMAKESHIFT_INTERFACE_COMPILE_SETTINGS
    BRIEF_DOCS "compile settings used for target interface"
    FULL_DOCS "compile settings used for target interface")
define_property(TARGET
    PROPERTY CMAKESHIFT_RAW_COMPILE_SETTINGS
    BRIEF_DOCS "compile settings used for target"
    FULL_DOCS "compile settings used for target")
define_property(TARGET
    PROPERTY CMAKESHIFT_INTERFACE_RAW_COMPILE_SETTINGS
    BRIEF_DOCS "compile settings used for target interface"
    FULL_DOCS "compile settings used for target interface")
define_property(TARGET
    PROPERTY CMAKESHIFT_SUPPRESSED_COMPILE_SETTINGS
    BRIEF_DOCS "compile settings to be suppressed for target"
    FULL_DOCS "compile settings to be suppressed for target")
define_property(TARGET
    PROPERTY CMAKESHIFT_SUPPRESSED_INTERFACE_COMPILE_SETTINGS
    BRIEF_DOCS "compile settings to be suppressed for target interface"
    FULL_DOCS "compile settings to be suppressed for target interface")
define_property(TARGET
    PROPERTY CMAKESHIFT_ARCHITECTURE_HAVE_FUSED_MULTIPLY_ADD
    BRIEF_DOCS "determines if target architecture supports fused multiply--add instructions"
    FULL_DOCS "determines if target architecture supports fused multiply--add instructions")
define_property(TARGET
    PROPERTY CMAKESHIFT_ARCHITECTURE_PREFER_AVX512
    BRIEF_DOCS "determines if target architecture prefers AVX-512 instructions"
    FULL_DOCS "determines if target architecture prefers AVX-512 instructions")


include(CMakeshift/detail/Trace)


set(CMAKESHIFT_PRIVATE_COMPILE_SETTINGS "" CACHE STRING "Default private compile settings to be applied to all targets with settings")
set(CMAKESHIFT_PUBLIC_COMPILE_SETTINGS "" CACHE STRING "Default public compile settings to be applied to all targets with settings")
set(CMAKESHIFT_INTERFACE_COMPILE_SETTINGS "" CACHE STRING "Default interface compile settings to be applied to all targets with settings")


set(_CMAKESHIFT_KNOWN_CUMULATIVE_SETTINGS "")
set(_CMAKESHIFT_KNOWN_SETTINGS "")
include(CMakeshift/detail/Settings-Default)
include(CMakeshift/detail/Settings-Diagnostics)
include(CMakeshift/detail/Settings-RuntimeChecks)
include(CMakeshift/detail/Settings-Architecture)
include(CMakeshift/detail/Settings-Other)


# Set known compile options for the target. 
#
#     cmakeshift_target_compile_settings(
#          <TARGET>|TARGETS <TARGET>...
#         PRIVATE|PUBLIC|INTERFACE <SETTING>...)
#
#
# Supported values for <SETTING>:
#
#     default                                   default options everyone can agree on:
#         default-base                              uncontroversial settings
#         default-experimental                      enable uncontroversial compiler improvements currently marked as experimental
#         default-output-directory                  place executables and shared libraries in ${PROJECT_BINARY_DIR}
#         default-utf8-source                       source files use UTF-8 encoding
#         default-windows-unicode                   UNICODE and _UNICODE are defined on Windows
#         default-conformance                       conformant behavior
#         default-debugjustmycode                   debugging convenience: "just my code"
#         default-debugdevicecode                   generate debug information for CUDA device code; disables optimizations in device code
#         default-shared                            export from shared objects is opt-in (via attribute or declspec)
#         default-inlines-hidden                    do not export inline functions (non-conformant but usually sane, and may speed up build)
#
#     utf8-codepage                             set UTF-8 as default narrow codepage on Windows
#   D hidden-inline                             do not export inline functions (non-conformant but usually sane, and may speed up build) (deprecated; use "default-inlines-hidden" instead)
#
#     diagnostics                               default diagnostic settings
#         diagnostics-pedantic                      increase warning level to pedantic level
#         diagnostics-paranoid                      increase warning level to paranoid level
#         diagnostics-disable-annoying              suppress annoying warnings (e.g. secure CRT, struct padding)
#     fatal-errors                              have the compiler stop at the first error
#   D pedantic                                  increase warning level (deprecated; use "diagnostics-pedantic" instead)
#   D disable-annoying-warnings                 suppress annoying warnings (e.g. secure CRT, struct padding) (deprecated; use "diagnostics-disable-annoying" instead)
#
#     runtime-checks                            enable runtime checks:
#         runtime-checks-stack                      enable stack guard
#         runtime-checks-asan                       enable address sanitizer
#         runtime-checks-ubsan                      enable UB sanitizer
#     debug-stdlib                              enable debug mode of standard library
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
#     target_compile_definitions(<target> PRIVATE $<IF:$<GENEX_EVAL:$<TARGET_PROPERTY:CMAKESHIFT_ARCHITECTURE_PREFER_AVX512>>PREFER_AVX512>)
#
# For architectures which support fused multiply--add opcodes, the target property
# "CMAKESHIFT_ARCHITECTURE_HAVE_FUSED_MULTIPLY_ADD" is set to TRUE. To make the target property accessible in source
# code, evaluate the target property in a generator expression:
#
#     target_compile_definitions(<target> PRIVATE $<IF:$<GENEX_EVAL:$<TARGET_PROPERTY:CMAKESHIFT_ARCHITECTURE_HAVE_FUSED_MULTIPLY_ADD>>HAVE_FUSED_MULTIPLY_ADD>)
#
# A project-wide default for the "cpu-architecture" setting can be set with the build option
# "CPU_ARCHITECTURE" defined in CMakeshift/TargetArchitecture.cmake.
#
#
# The arguments for the "cuda-architecture" and "cuda-gpu-code" settings are simply passed through to
# the CUDA compiler. For a list of admissible values, please refer to NVIDIA's NVCC documentation:
#
#     https://docs.nvidia.com/cuda/cuda-compiler-driver-nvcc/index.html
#
# A project-wide default for the "cuda-architecture" and "cuda-gpu-code" settings can be set with the
# build options "CUDA_ARCHITECTURE" and "CUDA_GPU_CODE" defined in CMakeshift/TargetArchitecture.cmake.
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
#     # enables all options in "default" except for "default-debugjustmycode"
#     cmakeshift_target_compile_settings(foo
#         PRIVATE
#             default no-default-debugjustmycode)
# 
# Settings prefixed with a 'D' are deprecated.
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
            foreach(_SETTING IN LISTS _CMAKE_CUMULATIVE_SETTING_${SETTING})
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
            foreach(_SETTING IN LISTS _CMAKE_CUMULATIVE_SETTING_${SETTING})
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
        _cmakeshift_settings_default()

        if(NOT _SETTING_SET)
            set(_SETTING_SET TRUE)
            _cmakeshift_settings_diagnostics()
        endif()

        if(NOT _SETTING_SET)
            set(_SETTING_SET TRUE)
            _cmakeshift_settings_runtime_checks()
        endif()

        if(NOT _SETTING_SET)
            set(_SETTING_SET TRUE)
            _cmakeshift_settings_architecture()
        endif()

        if(NOT _SETTING_SET)
            set(_SETTING_SET TRUE)
            _cmakeshift_settings_other()
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

        get_target_property(_CURRENT_SETTINGS ${TARGET_NAME} CMAKESHIFT_COMPILE_SETTINGS)
        if(NOT _CURRENT_SETTINGS)
            set(_TARGET_FIRST_TOUCH TRUE) # no settings have been set on the target before; remember this so we can apply global settings
            set(_CURRENT_SETTINGS "") # set to "NOTFOUND" if target property doesn't exist
        endif()
        cmakeshift_get_target_property_(_CURRENT_INTERFACE_SETTINGS CMAKESHIFT_INTERFACE_COMPILE_SETTINGS)
        cmakeshift_get_target_property_(_RAW_SETTINGS CMAKESHIFT_RAW_COMPILE_SETTINGS)
        cmakeshift_get_target_property_(_RAW_INTERFACE_SETTINGS CMAKESHIFT_INTERFACE_RAW_COMPILE_SETTINGS)
        cmakeshift_get_target_property_(_SUPPRESSED_SETTINGS CMAKESHIFT_SUPPRESSED_COMPILE_SETTINGS)
        cmakeshift_get_target_property_(_SUPPRESSED_INTERFACE_SETTINGS CMAKESHIFT_SUPPRESSED_INTERFACE_COMPILE_SETTINGS)
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
                set(SCOPE_PRIVATE "${CMAKESHIFT_PRIVATE_COMPILE_SETTINGS}" "${CMAKESHIFT_PUBLIC_COMPILE_SETTINGS}" "${SCOPE_PRIVATE}")
                
                # Look for build option CPU_TARGET_ARCHITECTURE.
                if(DEFINED CPU_TARGET_ARCHITECTURE AND NOT CPU_TARGET_ARCHITECTURE STREQUAL "")
                    set(SCOPE_PRIVATE "cpu-architecture=${CPU_TARGET_ARCHITECTURE}" "${SCOPE_PRIVATE}")
                endif()
                
                # Look for build options CUDA_TARGET_ARCHITECTURE and CUDA_GPU_CODE.
                if(HAVE_CUDA)
                    if(DEFINED CUDA_TARGET_ARCHITECTURE AND NOT CUDA_TARGET_ARCHITECTURE STREQUAL "")
                        set(SCOPE_PRIVATE "cuda-architecture=${CUDA_TARGET_ARCHITECTURE}" "${SCOPE_PRIVATE}")
                    endif()
                    if(DEFINED CUDA_GPU_CODE AND NOT CUDA_GPU_CODE STREQUAL "")
                        set(SCOPE_PRIVATE "cuda-gpu-code=${CUDA_GPU_CODE}" "${SCOPE_PRIVATE}")
                    endif()
                endif()
            endif()
            set(SCOPE_INTERFACE "${CMAKESHIFT_INTERFACE_COMPILE_SETTINGS}" "${CMAKESHIFT_PUBLIC_COMPILE_SETTINGS}" "${SCOPE_INTERFACE}")
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
                CMAKESHIFT_COMPILE_SETTINGS "${_CURRENT_SETTINGS}"
                CMAKESHIFT_INTERFACE_COMPILE_SETTINGS "${_CURRENT_INTERFACE_SETTINGS}"
                CMAKESHIFT_RAW_COMPILE_SETTINGS "${_RAW_SETTINGS}"
                CMAKESHIFT_RAW_INTERFACE_COMPILE_SETTINGS "${_RAW_INTERFACE_SETTINGS}"
                CMAKESHIFT_SUPPRESSED_COMPILE_SETTINGS "${_SUPPRESSED_SETTINGS}"
                CMAKESHIFT_SUPPRESSED_INTERFACE_COMPILE_SETTINGS "${_SUPPRESSED_INTERFACE_SETTINGS}")
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
