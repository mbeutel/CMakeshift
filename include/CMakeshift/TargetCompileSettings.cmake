
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


# Set known compile options for the target. 
#
#     cmakeshift_target_compile_settings(<target>
#         PRIVATE|PUBLIC|INTERFACE <OPT>...)
#
# Supported values for <OPT>:
#
#     default                       default options everyone can agree on:
#         default-base                  uncontroversial settings
#         default-triplet               heed linking options of selected Vcpkg triplet
#         default-conformance           conformant behavior
#         default-debugjustmycode       debugging convenience: "just my code"
#         default-shared                export from shared objects is opt-in (via attribute or declspec)
#     hidden-inline                 do not export inline functions (non-conformant but usually sane)
#     pedantic                      increase warning level
#     fatal-errors                  have the compiler stop at the first error
#     disable-annoying-warnings     suppress annoying warnings (e.g. unknown pragma)
#     runtime-checks                enable runtime checks:
#         runtime-checks-stack          enable stack guard
#         runtime-checks-asan           enable address sanitizer
#         runtime-checks-ubsan          enable UB sanitizer
#         runtime-checks-stdlib         enable standard library runtime checks
#
#     Prefixing a sub-option with "no-" suppresses it when the summary option is used:
#
#         # enables all options in "default" except for "default-debugging"
#         cmakeshift_target_compile_settings(foo
#             PRIVATE
#                 default no-default-debugging)
#
#     Note that generator expressions are not supported for suppressed options.
#
function(CMAKESHIFT_TARGET_COMPILE_SETTINGS TARGET_NAME)

    function(CMAKESHIFT_UPDATE_CACHE_VARIABLE_ VAR_NAME VALUE)
        get_property(HELP_STRING CACHE ${VAR_NAME} PROPERTY HELPSTRING)
        get_property(VAR_TYPE CACHE ${VAR_NAME} PROPERTY TYPE)
        set(${VAR_NAME} ${VALUE} CACHE ${VAR_TYPE} "${HELP_STRING}" FORCE)
    endfunction()

    set(_NO_DEFAULT_BASE FALSE)
    set(_NO_DEFAULT_TRIPLET FALSE)
    set(_NO_DEFAULT_CONFORMANCE FALSE)
    set(_NO_DEFAULT_DEBUGJMC FALSE)
    set(_NO_DEFAULT_SHARED FALSE)
    set(_NO_HIDDEN_INLINE FALSE)
    set(_NO_PEDANTIC FALSE)
    set(_NO_FATAL_ERRORS FALSE)
    set(_NO_DISABLE_ANNOYING_WARNINGS FALSE)
    set(_NO_RTC_STACK FALSE)
    set(_NO_RTC_ASAN FALSE)
    set(_NO_RTC_UBSAN FALSE)
    set(_NO_RTC_STDLIB FALSE)

    function(CMAKESHIFT_TARGET_COMPILE_SETTING_ACCUMULATE_ TARGET_NAME SCOPE OPTION0)
        if(NOT OPTION0 MATCHES "^[Nn][Oo]-([A-Za-z-]+)$")
            return()
        endif()
        set(OPTION1 "no-${CMAKE_MATCH_1}")
        if(NOT OPTION1)
            return()
        endif()
        string(TOLOWER "${OPTION1}" OPTION)

        if(OPTION STREQUAL "no-default-base")
            set(_NO_DEFAULT_BASE TRUE PARENT_SCOPE)
        elseif(OPTION STREQUAL "no-default-triplet")
            set(_NO_DEFAULT_TRIPLET TRUE PARENT_SCOPE)
        elseif(OPTION STREQUAL "no-default-conformance")
            set(_NO_DEFAULT_CONFORMANCE TRUE PARENT_SCOPE)
        elseif(OPTION STREQUAL "no-default-debugjustmycode")
            set(_NO_DEFAULT_DEBUGJMC TRUE PARENT_SCOPE)
        elseif(OPTION STREQUAL "no-default-shared")
            set(_NO_DEFAULT_SHARED TRUE PARENT_SCOPE)
        elseif(OPTION STREQUAL "no-hidden-inline")
            set(_NO_HIDDEN_INLINE TRUE PARENT_SCOPE)
        elseif(OPTION STREQUAL "no-pedantic")
            set(_NO_PEDANTIC TRUE PARENT_SCOPE)
        elseif(OPTION STREQUAL "no-fatal-errors")
            set(_NO_FATAL_ERRORS TRUE PARENT_SCOPE)
        elseif(OPTION STREQUAL "no-disable-annoying-warnings")
            set(_NO_DISABLE_ANNOYING_WARNINGS TRUE PARENT_SCOPE)
        elseif(OPTION STREQUAL "runtime-checks-stack")
            set(_NO_RTC_STACK TRUE PARENT_SCOPE)
        elseif(OPTION STREQUAL "runtime-checks-asan")
            set(_NO_RTC_ASAN TRUE PARENT_SCOPE)
        elseif(OPTION STREQUAL "runtime-checks-ubsan")
            set(_NO_RTC_UBSAN TRUE PARENT_SCOPE)
        elseif(OPTION STREQUAL "runtime-checks-stdlib")
            set(_NO_RTC_STDLIB TRUE PARENT_SCOPE)
        else()
            message(SEND_ERROR "Unknown target option \"${OPTION}\"")
        endif()
    endfunction()

    function(CMAKESHIFT_TARGET_COMPILE_SETTING_APPLY_ TARGET_NAME SCOPE OPTION0)
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

        set(FOUND FALSE)

        # buggy stdlib workarounds
        set(HAVE_UBSAN FALSE)
        set(HAVE_RTC_STDLIB FALSE)

        if((OPTION STREQUAL "default" OR OPTION STREQUAL "default-base") AND NOT _NO_DEFAULT_BASE)
            set(FOUND TRUE)
            # default options everyone can agree on
            if(MSVC)
                # enable /bigobj switch to permit more than 2^16 COMDAT sections per .obj file (can be useful in heavily templatized code)
                target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}/bigobj${RB}")

                # remove unreferenced COMDATs to improve linker throughput
                target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}/Zc:inline${RB}") # available since pre-modern VS 2013 Update 2
            endif()
        endif()

        if((OPTION STREQUAL "default" OR OPTION STREQUAL "default-triplet") AND NOT _NO_DEFAULT_TRIPLET)
            set(FOUND TRUE)
            # heed linking options of selected Vcpkg triplet
            if(MSVC AND VCPKG_CRT_LINKAGE)
                if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
                    set(_CRT_FLAG "D")
                elseif(VCPKG_CRT_LINKAGE STREQUAL "static")
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
        endif()

        if((OPTION STREQUAL "default" OR OPTION STREQUAL "default-conformance") AND NOT _NO_DEFAULT_CONFORMANCE)
            set(FOUND TRUE)
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
        endif()

        if((OPTION STREQUAL "default" OR OPTION STREQUAL "default-debugjustmycode") AND NOT _NO_DEFAULT_DEBUGJMC)
            set(FOUND TRUE)
            # enable debugging aids

            if(MSVC)
                # enable Just My Code for debugging convenience
                if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 19.15)
                    target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}$<$<CONFIG:Debug>:/JMC>${RB}") # available since VS 2017 15.8
                endif()
            endif()
        endif()

        if((OPTION STREQUAL "default" OR OPTION STREQUAL "default-shared") AND NOT _NO_DEFAULT_SHARED)
            set(FOUND TRUE)
            # don't export symbols from shared object libraries unless explicitly annotated
            get_property(_ENABLED_LANGUAGES GLOBAL PROPERTY ENABLED_LANGUAGES)
            foreach(LANG IN ITEMS C CXX CUDA)
                list(FIND _ENABLED_LANGUAGES "${LANG}" _RESULT)
                if(NOT _RESULT EQUAL -1)
                    set_target_properties(${TARGET_NAME} PROPERTIES ${LANG}_VISIBILITY_PRESET hidden)
                endif()
            endforeach()
        endif()

        if(OPTION STREQUAL "hidden-inline" AND NOT _NO_HIDDEN_INLINE)
            set(FOUND TRUE)
            # don't export inline functions
            set_target_properties(${TARGET_NAME} PROPERTIES VISIBILITY_INLINES_HIDDEN TRUE)
        endif()

        if(OPTION STREQUAL "pedantic" AND NOT _NO_PEDANTIC)
            set(FOUND TRUE)
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
        endif()

        if(OPTION STREQUAL "fatal-errors" AND NOT _NO_FATAL_ERRORS)
            set(FOUND TRUE)
            # every error is fatal; stop after reporting first error
            if(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
                target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}-fmax-errors=1${RB}")
            elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
                target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}-ferror-limit=1${RB}")
            endif()
        endif()

        if(OPTION STREQUAL "disable-annoying-warnings" AND NOT _NO_DISABLE_ANNOYING_WARNINGS)
            set(FOUND TRUE)
            # disable annoying warnings
            if(MSVC)
                # C4324 (structure was padded due to alignment specifier)
                target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}/wd4324${RB}")
            elseif(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX OR (CMAKE_CXX_COMPILER_ID MATCHES "Clang"))
                target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}-Wno-unknown-pragmas${RB}")
            endif()
        endif()

        if((OPTION STREQUAL "runtime-checks" OR OPTION STREQUAL "runtime-checks-stack") AND NOT _NO_RTC_STACK)
            set(FOUND TRUE)
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
        endif()

        if((OPTION STREQUAL "runtime-checks" OR OPTION STREQUAL "runtime-checks-asan") AND NOT _NO_RTC_ASAN)
            set(FOUND TRUE)
            # enable AddressSanitizer
            if(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX OR (CMAKE_CXX_COMPILER_ID MATCHES "Clang"))
                target_compile_options(${TARGET_NAME} PRIVATE "${LB}-fsanitize=address${RB}")
                target_link_libraries(${TARGET_NAME} PRIVATE "${LB}-fsanitize=address${RB}")
            endif()
        endif()

        if((OPTION STREQUAL "runtime-checks" OR OPTION STREQUAL "runtime-checks-ubsan") AND NOT _NO_RTC_UBSAN)
            set(FOUND TRUE)
            # enable UndefinedBehaviorSanitizer
            if(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
                target_compile_options(${TARGET_NAME} PRIVATE "${LB}-fsanitize=undefined${RB}")
                target_link_libraries(${TARGET_NAME} PRIVATE "${LB}-fsanitize=undefined${RB}")

            elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
                # UBSan can cause linker errors in Clang 7, and it raises issues in libc++ debugging code
                if((CMAKE_CXX_COMPILER_VERSION VERSION_LESS 7.0) AND NOT HAVE_RTC_STDLIB)
                    set(HAVE_UBSAN TRUE)
                    target_compile_options(${TARGET_NAME} PRIVATE "${LB}-fsanitize=undefined${RB}")
                    target_link_libraries(${TARGET_NAME} PRIVATE "${LB}-fsanitize=undefined${RB}")
                endif()
            endif()
        endif()

        if((OPTION STREQUAL "runtime-checks" OR OPTION STREQUAL "runtime-checks-stdlib") AND NOT _NO_RTC_STDLIB)
            set(FOUND TRUE)
            if(MSVC)
                # enable checked iterators
                target_compile_definitions(${TARGET_NAME} PRIVATE "${LB}$<$<NOT:$<CONFIG:Debug>>:_ITERATOR_DEBUG_LEVEL=1>${RB}")

            elseif(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
                # enable libstdc++ debug mode
                target_compile_definitions(${TARGET_NAME} PRIVATE "${LB}$<$<CONFIG:Debug>:_GLIBCXX_DEBUG>${RB}")

            elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
                # UBSan raises issues in libc++ debugging code
                if(NOT HAVE_UBSAN)
                    set(HAVE_RTC_STDLIB TRUE)
                    # enable libc++ debug mode
                    target_compile_definitions(${TARGET_NAME} PRIVATE "${LB}$<IF:$<CONFIG:Debug>,_LIBCPP_DEBUG=1,_LIBCPP_DEBUG=0>${RB}")
                endif()
            endif()
        endif()

        if(NOT FOUND)
            message(SEND_ERROR "Unknown target option \"${OPTION}\"")
        endif()
    endfunction()

    set(options "")
    set(oneValueArgs "")
    set(multiValueArgs PRIVATE INTERFACE PUBLIC)
    cmake_parse_arguments(PARSE_ARGV 1 "SCOPE" "${options}" "${oneValueArgs}" "${multiValueArgs}")
    if(SCOPE_UNPARSED_ARGUMENTS)
        message(SEND_ERROR "Invalid argument keywords \"${SCOPE_UNPARSED_ARGUMENTS}\"; expected PRIVATE, INTERFACE, or PUBLIC")
    endif()

    foreach(arg IN LISTS SCOPE_PRIVATE)
        cmakeshift_target_compile_setting_accumulate_(${TARGET_NAME} PRIVATE "${arg}")
    endforeach()
    foreach(arg IN LISTS SCOPE_INTERFACE)
        cmakeshift_target_compile_setting_accumulate_(${TARGET_NAME} INTERFACE "${arg}")
    endforeach()
    foreach(arg IN LISTS SCOPE_PUBLIC)
        cmakeshift_target_compile_setting_accumulate_(${TARGET_NAME} PUBLIC "${arg}")
    endforeach()

    foreach(arg IN LISTS SCOPE_PRIVATE)
        cmakeshift_target_compile_setting_apply_(${TARGET_NAME} PRIVATE "${arg}")
    endforeach()
    foreach(arg IN LISTS SCOPE_INTERFACE)
        cmakeshift_target_compile_setting_apply_(${TARGET_NAME} INTERFACE "${arg}")
    endforeach()
    foreach(arg IN LISTS SCOPE_PUBLIC)
        cmakeshift_target_compile_setting_apply_(${TARGET_NAME} PUBLIC "${arg}")
    endforeach()
endfunction()
