
# CMakeshift
# TargetCompileSettings.cmake
# Author: Moritz Beutel


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


define_property(TARGET
    PROPERTY CMAKESHIFT_COMPILE_SETTINGS
    BRIEF_DOCS "compile settings used for target"
    FULL_DOCS "compile settings used for target")
define_property(TARGET
    PROPERTY CMAKESHIFT_INTERFACE_COMPILE_SETTINGS
    BRIEF_DOCS "compile settings used for target"
    FULL_DOCS "compile settings used for target")


# Set known compile options for the target. 
#
#     cmakeshift_target_compile_settings(<target>
#         PRIVATE|PUBLIC|INTERFACE <OPT>...)
#
# Supported values for <OPT>:
#
#     default                           default options everyone can agree on:
#         default-base                      uncontroversial settings
#         default-output-directory          place executables and shared libraries in ${PROJECT_BINARY_DIR}
#         default-utf8-source               source files use UTF-8 encoding
#         default-windows-unicode           UNICODE and _UNICODE are defined on Windows
#         default-triplet                   heed linking options of selected Vcpkg triplet
#         default-conformance               conformant behavior
#         default-debugjustmycode           debugging convenience: "just my code"
#         default-shared                    export from shared objects is opt-in (via attribute or declspec)
#     hidden-inline                     do not export inline functions (non-conformant but usually sane)
#     fatal-errors                      have the compiler stop at the first error
#   D pedantic                          increase warning level
#   D disable-annoying-warnings         suppress annoying warnings (e.g. unknown pragma, secure CRT)
#     diagnostics                       default diagnostic settings
#         diagnostics-pedantic          increase warning level to pedantic level
#         diagnostics-paranoid          increase warning level to paranoid level
#         diagnostics-disable-annoying      suppress annoying warnings (e.g. unknown pragma, secure CRT, struct padding)
#     runtime-checks                    enable runtime checks:
#         runtime-checks-stack              enable stack guard
#         runtime-checks-asan               enable address sanitizer
#         runtime-checks-ubsan              enable UB sanitizer
#     debug-stdlib                      enable debug mode of standard library
#
#     Prefixing a sub-option with "no-" suppresses it when the summary option is used:
#
#         # enables all options in "default" except for "default-debugjustmycode"
#         cmakeshift_target_compile_settings(foo
#             PRIVATE
#                 default no-default-debugjustmycode)
#
#     Note that generator expressions are not supported for suppressed options.
#
#     When using "debug-stdlib", note that this option may alter the object layout of containers.
#     If your target exchanges container instantiations with other targets, those must also be
#     compiled with "debug-stdlib", otherwise you may get silent data corruption at runtime.
#
function(CMAKESHIFT_TARGET_COMPILE_SETTINGS TARGET_NAME)

    function(CMAKESHIFT_UPDATE_CACHE_VARIABLE_ VAR_NAME VALUE)
        get_property(HELP_STRING CACHE ${VAR_NAME} PROPERTY HELPSTRING)
        get_property(VAR_TYPE CACHE ${VAR_NAME} PROPERTY TYPE)
        set(${VAR_NAME} ${VALUE} CACHE ${VAR_TYPE} "${HELP_STRING}" FORCE)
    endfunction()

    set(_KNOWN_CUMULATIVE_SETTINGS
        "default"
        "diagnostics"
        "runtime-checks")

    set(_KNOWN_SETTINGS
        "default-base"
        "default-output-directory"
        "default-utf8-source"
        "default-windows-unicode"
        "default-triplet"
        "default-conformance"
        "default-debugjustmycode"
        "default-shared"
        "hidden-inline"
        "fatal-errors"
        "pedantic"
        "disable-annoying-warnings"
        "diagnostics-pedantic"
        "diagnostics-paranoid"
        "diagnostics-disable-annoying"
        "runtime-checks-stack"
        "runtime-checks-asan"
        "runtime-checks-ubsan"
        "debug-stdlib")

    get_target_property(_CURRENT_SETTINGS ${TARGET_NAME} CMAKESHIFT_COMPILE_SETTINGS)
    if(NOT _CURRENT_SETTINGS)
        set(_CURRENT_SETTINGS "") # set to "NOTFOUND" if target property doesn't exist
    endif()
    set(_CURRENT_SETTINGS_0 "${_CURRENT_SETTINGS}")
    get_target_property(_CURRENT_INTERFACE_SETTINGS_0 ${TARGET_NAME} CMAKESHIFT_INTERFACE_COMPILE_SETTINGS)
    get_target_property(_CURRENT_INTERFACE_SETTINGS ${TARGET_NAME} CMAKESHIFT_INTERFACE_COMPILE_SETTINGS)
    if(NOT _CURRENT_INTERFACE_SETTINGS)
        set(_CURRENT_INTERFACE_SETTINGS "") # set to "NOTFOUND" if target property doesn't exist
    endif()
    set(_CURRENT_INTERFACE_SETTINGS_0 "${_CURRENT_INTERFACE_SETTINGS}")

    set(_SUPPRESSED_SETTINGS ${_CURRENT_SETTINGS})
    set(_SUPPRESSED_INTERFACE_SETTINGS ${_CURRENT_INTERFACE_SETTINGS})

    function(CMAKESHIFT_TARGET_COMPILE_SETTING_ACCUMULATE_ TARGET_NAME SCOPE OPTION0)
        if(SCOPE STREQUAL INTERFACE)
            set(_INTERFACE "_INTERFACE")
        else()
            set(_INTERFACE "")
        endif()

        if(NOT OPTION0 MATCHES "^[Nn][Oo]-([A-Za-z-]+)$")
            return()
        endif()
        set(OPTION1 "${CMAKE_MATCH_1}")
        if(NOT OPTION1)
            return()
        endif()
        string(TOLOWER "${OPTION1}" OPTION)

        # Is the setting known?
        if(NOT "${OPTION}" IN_LIST _KNOWN_SETTINGS)
            if("${OPTION}" IN_LIST _KNOWN_CUMULATIVE_SETTINGS)
                message(SEND_ERROR "\"no-${OPTION}\": Cannot suppress a cumulative option")
            else()
                message(SEND_ERROR "Unknown target option \"${OPTION}\", don't know what to do with option \"no-${OPTION}\"")
            endif()
            return()
        endif()

        # Has it already been set or suppressed?
        if("${OPTION}" IN_LIST _SUPPRESSED${_INTERFACE}_SETTINGS)
            if("${OPTION}" IN_LIST _CURRENT${_INTERFACE}_SETTINGS_0)
                message(WARNING "Cannot suppress option \"${OPTION}\" because it was enabled in a previous call to cmakeshift_target_compile_settings().")
            endif()
            return()
        endif()

        list(APPEND _SUPPRESSED${_INTERFACE}_SETTINGS "${OPTION}")
    endfunction()

    function(CMAKESHIFT_TARGET_COMPILE_SETTING_APPLY_ TARGET_NAME SCOPE OPTION0)
        if(SCOPE STREQUAL INTERFACE)
            set(_INTERFACE "_INTERFACE")
        else()
            set(_INTERFACE "")
        endif()

        if(OPTION0 MATCHES "^\\$<(.+):([A-Za-z-]+)>$")
            set(LB "$<${CMAKE_MATCH_1}:")
            set(RB ">")
            set(OPTION1 "${CMAKE_MATCH_2}")
        else()
            set(LB "")
            set(RB "")
            set(OPTION1 "${OPTION0}")
        endif()

        if(NOT OPTION1)
            return()
        endif()
        string(TOLOWER "${OPTION1}" OPTION)

        if(OPTION MATCHES "^no-[A-Za-z-]+$")
            if(NOT LB STREQUAL "")
                message(SEND_ERROR "\"${OPTION0}\": Cannot use generator expression with suppressed options")
            endif()
            return()
        endif()

        # Is it a cumulative setting?
        if("${OPTION}" IN_LIST _KNOWN_CUMULATIVE_SETTINGS)
            # Recur and set all settings that match the stem.
            foreach(_SETTING IN LISTS _KNOWN_SETTINGS)
                if(_SETTING MATCHES "^${OPTION}-[A-Za-z-]+$")
                    cmakeshift_target_compile_setting_apply_(${TARGET_NAME} ${SCOPE} ${_SETTING})
                    set(_CURRENT${_INTERFACE}_SETTINGS "${_CURRENT${_INTERFACE}_SETTINGS}" PARENT_SCOPE)
                    set(_SUPPRESSED${_INTERFACE}_SETTINGS "${_SUPPRESSED${_INTERFACE}_SETTINGS}" PARENT_SCOPE)
                endif()
            endforeach()
            return()
        endif()

        # Is the setting known?
        if(NOT "${OPTION}" IN_LIST _KNOWN_SETTINGS)
            message(SEND_ERROR "Unknown target option \"${OPTION}\"")
            return()
        endif()

        # Has it already been set or suppressed?
        if("${OPTION}" IN_LIST _SUPPRESSED${_INTERFACE}_SETTINGS)
            return()
        endif()

        set(_SETTING_SET TRUE)

        if(OPTION STREQUAL "default-base")
            # default options everyone can agree on
            if(MSVC)
                # enable /bigobj switch to permit more than 2^16 COMDAT sections per .obj file (can be useful in heavily templatized code)
                target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}/bigobj${RB}")

                # remove unreferenced COMDATs to improve linker throughput
                target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}/Zc:inline${RB}") # available since pre-modern VS 2013 Update 2
            endif()

        elseif(OPTION STREQUAL "default-output-directory")
            # place binaries in ${PROJECT_BINARY_DIR}
            get_target_property(_TARGET_TYPE ${TARGET_NAME} TYPE)
            if(_TARGET_TYPE STREQUAL SHARED_LIBRARY OR _TARGET_TYPE STREQUAL MODULE_LIBRARY OR _TARGET_TYPE STREQUAL EXECUTABLE)
                set_target_properties(${TARGET_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}" LIBRARY_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}")
            endif()

        elseif(OPTION STREQUAL "default-utf8-source")
            # source files use UTF-8 encoding
            if(MSVC)
                target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}/utf-8${RB}")
            endif()

        elseif(OPTION STREQUAL "default-windows-unicode")
            # UNICODE and _UNICODE are defined on Windows
            target_compile_definitions(${TARGET_NAME} ${SCOPE} "${LB}$<$<PLATFORM_ID:Windows>:UNICODE>${RB}" "${LB}$<$<PLATFORM_ID:Windows>:_UNICODE>${RB}")

        elseif(OPTION STREQUAL "default-triplet")
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

        elseif(OPTION STREQUAL "default-conformance")
            # configure compilers to be ISO C++ conformant

            # disable language extensions
            set_target_properties(${TARGET_NAME} PROPERTIES CXX_EXTENSIONS OFF)

            if(MSVC)
                # make `volatile` behave as specified by the language standard, as opposed to the quasi-atomic semantics VC++ implements by default
                target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}/volatile:iso${RB}")

                # enable permissive mode (prefer already rejuvenated parts of compiler for better conformance)
                if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 19.10)
                    target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}/permissive-${RB}") # available since VS 2017 15.0
                endif()

                # enable "extern constexpr" support
                if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 19.13)
                    target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}/Zc:externConstexpr${RB}") # available since VS 2017 15.6
                endif()

                # enable updated __cplusplus macro value
                if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 19.14)
                    target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}/Zc:__cplusplus${RB}") # available since VS 2017 15.7
                endif()
            endif()

        elseif(OPTION STREQUAL "default-debugjustmycode")
            # enable debugging aids

            if(MSVC)
                # enable Just My Code for debugging convenience
                if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 19.15)
                    target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}$<$<CONFIG:Debug>:/JMC>${RB}") # available since VS 2017 15.8
                endif()
            endif()

        elseif(OPTION STREQUAL "default-shared")
            # don't export symbols from shared object libraries unless explicitly annotated
            get_property(_ENABLED_LANGUAGES GLOBAL PROPERTY ENABLED_LANGUAGES)
            foreach(LANG IN ITEMS C CXX CUDA)
                if("${LANG}" IN_LIST _ENABLED_LANGUAGES)
                    set_target_properties(${TARGET_NAME} PROPERTIES ${LANG}_VISIBILITY_PRESET hidden)
                endif()
            endforeach()

        elseif(OPTION STREQUAL "hidden-inline")
            # don't export inline functions
            set_target_properties(${TARGET_NAME} PROPERTIES VISIBILITY_INLINES_HIDDEN TRUE)

        elseif(OPTION STREQUAL "pedantic" OR OPTION STREQUAL "diagnostics-pedantic")
            # highest sensible level for warnings and diagnostics
            if(MSVC)
                # remove "/Wx" from CMAKE_CXX_FLAGS if present, as VC++ doesn't tolerate more than one "/Wx" flag
                if(CMAKE_CXX_FLAGS MATCHES "/W[0-4]")
                    string(REGEX REPLACE "/W[0-4]" " " CMAKE_CXX_FLAGS_NEW "${CMAKE_CXX_FLAGS}")
                    cmakeshift_update_cache_variable_(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS_NEW}")
                endif()
                target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}/W4${RB}")
            elseif(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX OR (CMAKE_CXX_COMPILER_ID MATCHES "Clang"))
                target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}-Wall${RB}" "${LB}-Wextra${RB}" "${LB}-pedantic${RB}")
            endif()

        elseif(OPTION STREQUAL "diagnostics-paranoid")
            # enable extra paranoid warnings
            if(MSVC)
                target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}/w44062${RB}") # enumerator 'identifier' in a switch of enum 'enumeration' is not handled
                target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}/w44242${RB}") # 'identifier': conversion from 'type1' to 'type2', possible loss of data
                target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}/w44254${RB}") # 'operator': conversion from 'type1' to 'type2', possible loss of data
                target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}/w44265${RB}") # 'class': class has virtual functions, but destructor is not virtual
                #target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}/w44365${RB}") # 'action': conversion from 'type_1' to 'type_2', signed/unsigned mismatch (cannot enable this one because it flags `container[signed_index]`)
            endif()

        elseif(OPTION STREQUAL "fatal-errors")
            # every error is fatal; stop after reporting first error
            if(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
                target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}-fmax-errors=1${RB}")
            elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
                target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}-ferror-limit=1${RB}")
            endif()

        elseif(OPTION STREQUAL "disable-annoying-warnings" OR OPTION STREQUAL "diagnostics-disable-annoying")
            # disable annoying warnings
            if(MSVC)
                # C4324 (structure was padded due to alignment specifier)
                target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}/wd4324${RB}")
                # secure CRT warnings (e.g. "use sprintf_s rather than sprintf")
                target_compile_definitions(${TARGET_NAME} ${SCOPE} "${LB}_CRT_SECURE_NO_WARNINGS${RB}")
            elseif(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX OR (CMAKE_CXX_COMPILER_ID MATCHES "Clang"))
                target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}-Wno-unknown-pragmas${RB}")
            endif()

        elseif(OPTION STREQUAL "runtime-checks-stack")
            if(MSVC)
                # VC++ already enables stack frame run-time error checking and detection of uninitialized values by default in debug builds

                # insert control flow guards
                target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}/guard:cf${RB}")
                target_link_libraries(${TARGET_NAME} ${SCOPE} "${LB}-guard:cf${RB}") # this flag also needs to be passed to the linker (CMake needs a leading '-' to recognize a flag here)
            endif()

            if(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
                # enable stack protector
                target_compile_options(${TARGET_NAME} PRIVATE "${LB}-fstack-protector${RB}")
            endif()

        elseif(OPTION STREQUAL "runtime-checks-asan")
            # enable AddressSanitizer
            if(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX OR (CMAKE_CXX_COMPILER_ID MATCHES "Clang"))
                target_compile_options(${TARGET_NAME} PRIVATE "${LB}-fsanitize=address${RB}")
                target_link_libraries(${TARGET_NAME} PRIVATE "${LB}-fsanitize=address${RB}")
            endif()

        elseif(OPTION STREQUAL "runtime-checks-ubsan")
            # enable UndefinedBehaviorSanitizer
            if(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
                target_compile_options(${TARGET_NAME} PRIVATE "${LB}-fsanitize=undefined${RB}")
                target_link_libraries(${TARGET_NAME} PRIVATE "${LB}-fsanitize=undefined${RB}")

            elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
                # UBSan can cause linker errors in Clang 6 and 7, and it raises issues in libc++ debugging code
                if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS 8.0)
                    message("Not enabling UBSan for target \"${TARGET_NAME}\" because it can cause linker errors in Clang 6 and 7.")
                    set(_SETTING_SET FALSE)
                elseif("debug-stdlib" IN_LIST _CURRENT${_INTERFACE}_SETTINGS)
                    message("Not enabling UBSan for target \"${TARGET_NAME}\" because it is known to raise issues in libc++ debugging code.")
                    set(_SETTING_SET FALSE)
                else()
                    target_compile_options(${TARGET_NAME} PRIVATE "${LB}-fsanitize=undefined${RB}")
                    target_link_libraries(${TARGET_NAME} PRIVATE "${LB}-fsanitize=undefined${RB}")
                endif()
            endif()

        elseif(OPTION STREQUAL "debug-stdlib")
            if(MSVC)
                # enable checked iterators
                target_compile_definitions(${TARGET_NAME} PRIVATE "${LB}$<$<NOT:$<CONFIG:Debug>>:_ITERATOR_DEBUG_LEVEL=1>${RB}")

            elseif(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
                # enable libstdc++ debug mode
                target_compile_definitions(${TARGET_NAME} PRIVATE "${LB}$<$<CONFIG:Debug>:_GLIBCXX_DEBUG>${RB}")

            elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
                if("runtime-checks-ubsan" IN_LIST _CURRENT${_INTERFACE}_SETTINGS)
                    message("Not enabling standard library debug mode for target \"${TARGET}\" because it uses UBSan, which is known to raise issues in libc++ debugging code.")
                    set(_SETTING_SET FALSE)
                else()
                    # enable libc++ debug mode
                    target_compile_definitions(${TARGET_NAME} PRIVATE "${LB}$<IF:$<CONFIG:Debug>,_LIBCPP_DEBUG=1,_LIBCPP_DEBUG=0>${RB}")
                endif()
            endif()
        endif()

        if(_SETTING_SET)
            set(_CURRENT${_INTERFACE}_SETTINGS "${_CURRENT${_INTERFACE}_SETTINGS}" "${OPTION}" PARENT_SCOPE)
            set(_SUPPRESSED${_INTERFACE}_SETTINGS "${_SUPPRESSED${_INTERFACE}_SETTINGS}" "${OPTION}" PARENT_SCOPE)
        endif()
    endfunction()

    set(options "")
    set(oneValueArgs "")
    set(multiValueArgs PRIVATE INTERFACE PUBLIC)
    cmake_parse_arguments(PARSE_ARGV 1 "SCOPE" "${options}" "${oneValueArgs}" "${multiValueArgs}")
    if(SCOPE_UNPARSED_ARGUMENTS)
        message(SEND_ERROR "Invalid argument keywords \"${SCOPE_UNPARSED_ARGUMENTS}\"; expected PRIVATE, INTERFACE, or PUBLIC")
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
            CMAKESHIFT_INTERFACE_COMPILE_SETTINGS "${_CURRENT_INTERFACE_SETTINGS}")

endfunction()
