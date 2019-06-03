
# CMakeshift
# TargetCompileSettings.cmake
# Author: Moritz Beutel


if(DEFINED _CMAKESHIFT_KNOWN_SETTINGS)
    return() # prevent multiple inclusion
endif()


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
#     cmakeshift_target_compile_settings(<target>
#         PRIVATE|PUBLIC|INTERFACE <SETTING>...)
#
#
# Supported values for <SETTING>:
#
#     default                                   default options everyone can agree on:
#         default-base                              uncontroversial settings
#         default-output-directory                  place executables and shared libraries in ${PROJECT_BINARY_DIR}
#         default-utf8-source                       source files use UTF-8 encoding
#         default-windows-unicode                   UNICODE and _UNICODE are defined on Windows
#         default-triplet                           heed linking options of selected Vcpkg triplet
#         default-conformance                       conformant behavior
#         default-debugjustmycode                   debugging convenience: "just my code"
#         default-shared                            export from shared objects is opt-in (via attribute or declspec)
# 
#   D hidden-inline                             do not export inline functions (non-conformant but usually sane) (deprecated; will either disappear or become part of "default")
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
#     cpu-architecture=<arch>                   generate code for CPU architecture <arch>
#     fp-model=<model>                          configure the floating-point model
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
function(CMAKESHIFT_TARGET_COMPILE_SETTINGS TARGET_NAME)

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

    function(CMAKESHIFT_TARGET_COMPILE_SETTING_ACCUMULATE_ TARGET_NAME SCOPE SETTING0)
        if(SCOPE STREQUAL INTERFACE)
            set(_INTERFACE "_INTERFACE")
        else()
            set(_INTERFACE "")
        endif()

        if(NOT SETTING0 MATCHES "^[Nn][Oo]-([A-Za-z-]+)=?$")
            return()
        endif()
        set(SETTING1 "${CMAKE_MATCH_1}")
        if(SETTING1 STREQUAL "")
            return()
        endif()
        string(TOLOWER "${SETTING1}" SETTING)

        # Is it a cumulative setting?
        if("${SETTING}" IN_LIST _CMAKESHIFT_KNOWN_CUMULATIVE_SETTINGS)
            # Recur and suppress all settings that match the stem.
            foreach(_SETTING IN LISTS _CMAKESHIFT_KNOWN_SETTINGS)
                if(_SETTING MATCHES "^${SETTING}-[A-Za-z-]+=?$") # this includes settings with arguments, e.g. "cpu-architecture="
                    cmakeshift_target_compile_setting_accumulate_(${TARGET_NAME} ${SCOPE} "no-${_SETTING}")
                    set(_SUPPRESSED${_INTERFACE}_SETTINGS "${_SUPPRESSED${_INTERFACE}_SETTINGS}" PARENT_SCOPE)
                endif()
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
    endfunction()

    function(CMAKESHIFT_TARGET_COMPILE_SETTING_APPLY_ TARGET_NAME SCOPE SETTING0)
        if(SCOPE STREQUAL INTERFACE)
            set(_INTERFACE "_INTERFACE")
        else()
            set(_INTERFACE "")
        endif()

        if(SETTING0 MATCHES "^\\$<(.+):([A-Za-z-]+(=.*)?)>$")
            set(LB "$<${CMAKE_MATCH_1}:")
            set(SETTING1 "${CMAKE_MATCH_2}")
            set(RB ">")
        else()
            set(LB "")
            set(SETTING1 "${SETTING0}")
            set(RB "")
        endif()

        if(SETTING1 MATCHES "^([A-Za-z-]+)(=)(.*)$")
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

        if(SETTING MATCHES "^no-[A-Za-z-]+$")
            if(NOT LB STREQUAL "")
                message(SEND_ERROR "cmakeshift_target_compile_settings(): \"${SETTING0}\": Cannot use generator expression with suppressed options")
            endif()
            return()
        endif()

        # Is it a cumulative setting?
        if("${SETTING}" IN_LIST _CMAKESHIFT_KNOWN_CUMULATIVE_SETTINGS)
            # Recur and set all settings that match the stem.
            foreach(_SETTING IN LISTS _CMAKESHIFT_KNOWN_SETTINGS)
                if(_SETTING MATCHES "^${SETTING}-[A-Za-z-]+$") # this implicitly skips settings with arguments, e.g. "cpu-architecture="
                    cmakeshift_target_compile_setting_apply_(${TARGET_NAME} ${SCOPE} "${LB}${_SETTING}${RB}")
                    set(_RAW_${_INTERFACE}_SETTINGS "${_RAW${_INTERFACE}_SETTINGS}" PARENT_SCOPE)
                    set(_CURRENT${_INTERFACE}_SETTINGS "${_CURRENT${_INTERFACE}_SETTINGS}" PARENT_SCOPE)
                endif()
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
        _cmakeshift_settings_default(${SETTING} "${VAL}" ${TARGET_NAME} ${SCOPE} "${LB}" "${RB}")

        if(NOT _SETTING_SET)
            set(_SETTING_SET TRUE)
            _cmakeshift_settings_diagnostics(${SETTING} "${VAL}" ${TARGET_NAME} ${SCOPE} "${LB}" "${RB}")
        endif()

        if(NOT _SETTING_SET)
            set(_SETTING_SET TRUE)
            _cmakeshift_settings_runtime_checks(${SETTING} "${VAL}" ${TARGET_NAME} ${SCOPE} "${LB}" "${RB}")
        endif()

        if(NOT _SETTING_SET)
            set(_SETTING_SET TRUE)
            _cmakeshift_settings_architecture(${SETTING} "${VAL}" ${TARGET_NAME} ${SCOPE} "${LB}" "${RB}")
        endif()

        if(NOT _SETTING_SET)
            set(_SETTING_SET TRUE)
            _cmakeshift_settings_other(${SETTING} "${VAL}" ${TARGET_NAME} ${SCOPE} "${LB}" "${RB}")
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

    set(options "")
    set(oneValueArgs "")
    set(multiValueArgs PRIVATE INTERFACE PUBLIC)
    cmake_parse_arguments(PARSE_ARGV 1 "SCOPE" "${options}" "${oneValueArgs}" "${multiValueArgs}")
    if(SCOPE_UNPARSED_ARGUMENTS)
        message(SEND_ERROR "cmakeshift_target_compile_settings(): Invalid argument keywords \"${SCOPE_UNPARSED_ARGUMENTS}\"; expected PRIVATE, INTERFACE, or PUBLIC")
    endif()

    # Apply global settings if this is the first call to `cmakeshift_target_compile_settings()` for this target.
    if(_TARGET_FIRST_TOUCH)
        set(SCOPE_PRIVATE "${CMAKESHIFT_PRIVATE_COMPILE_SETTINGS}" "${CMAKESHIFT_PUBLIC_COMPILE_SETTINGS}" "${SCOPE_PRIVATE}")
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
