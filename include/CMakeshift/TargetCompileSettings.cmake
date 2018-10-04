
# CMakeshift
# TargetCompileSettings.cmake
# Author: Moritz Beutel


# Set known compile options for the target. Supported options:
#
#     default                   some default options everyone can agree on (conformant behavior, debugging convenience, opt-in export from shared objects, etc.)
#     pedantic                  increase warning level
#     fatal-errors              have the compiler stop at the first error
#
function(CMAKESHIFT_TARGET_COMPILE_SETTINGS TARGET_NAME)

    function(CMAKESHIFT_UPDATE_CACHE_VARIABLE_ VAR_NAME VALUE)
        get_property(HELP_STRING CACHE ${VAR_NAME} PROPERTY HELPSTRING)
        get_property(VAR_TYPE CACHE ${VAR_NAME} PROPERTY TYPE)
        set(${VAR_NAME} ${VALUE} CACHE ${VAR_TYPE} "${HELP_STRING}" FORCE)
    endfunction()

    function(CMAKESHIFT_TARGET_COMPILE_SETTING_ TARGET_NAME SCOPE OPTION0)
        string(TOLOWER "${OPTION0}" OPTION)
        if(OPTION STREQUAL "default")
            # default options everyone can agree on
            if(MSVC)
                # enable /bigobj switch to permit more than 2^16 COMDAT sections per .obj file (can be useful in heavily templatized code)
                target_compile_options(${TARGET_NAME} ${SCOPE} "/bigobj")

                # make `volatile` behave as specified by the language standard, as opposed to the quasi-atomic semantics VC++ implements by default
                target_compile_options(${TARGET_NAME} ${SCOPE} "/volatile:iso")

                # remove unreferenced COMDATs to improve linker throughput
                target_compile_options(${TARGET_NAME} ${SCOPE} "/Zc:inline") # available since pre-modern VS 2013 Update 2

                # enable permissive mode (prefer already rejuvenated parts of compiler for better conformance)
                if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 19.10)
                    target_compile_options(${TARGET_NAME} ${SCOPE} "/permissive-") # available since VS 2017 15.0
                endif()

                # enable "extern constexpr" support
                if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 19.13)
                    target_compile_options(${TARGET_NAME} ${SCOPE} "/Zc:externConstexpr") # available since VS 2017 15.6
                endif()

                # enable updated __cplusplus macro value
                if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 19.14)
                    target_compile_options(${TARGET_NAME} ${SCOPE} "/Zc:__cplusplus") # available since VS 2017 15.7
                endif()

                # enable Just My Code for debugging convenience
                if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 19.15)
                    target_compile_options(${TARGET_NAME} ${SCOPE} "/JMC") # available since VS 2017 15.8
                endif()
            endif()

            # Don't export symbols from shared object libraries unless explicitly annotated.
            get_property(_ENABLED_LANGUAGES GLOBAL PROPERTY ENABLED_LANGUAGES)
            foreach(LANG IN ITEMS C CXX CUDA)
                list(FIND _ENABLED_LANGUAGES "${LANG}" _RESULT)
                if(NOT _RESULT EQUAL -1)
                    set_target_properties(${TARGET_NAME} PROPERTIES ${LANG}_VISIBILITY_PRESET hidden)
                endif()
            endforeach()

            # Don't export inline functions. (TODO: this is non-standard behavior; do we really want this?)
            #set_target_properties(${TARGET_NAME} PROPERTIES VISIBILITY_INLINES_HIDDEN TRUE)

        elseif(OPTION STREQUAL "pedantic")
            # highest sensible level for warnings and diagnostics
            if(MSVC)
                # remove "/Wx" from CMAKE_CXX_FLAGS if present, as VC++ doesn't tolerate more than one "/Wx" flag
                if(CMAKE_CXX_FLAGS MATCHES "/W[0-4]")
                    string(REGEX REPLACE "/W[0-4]" "" CMAKE_CXX_FLAGS_NEW "${CMAKE_CXX_FLAGS}")
                    cmakeshift_update_cache_variable_(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS_NEW}")
                endif()
                target_compile_options(${TARGET_NAME} ${SCOPE} "/W4")

                # disable annoying warnings:
                # C4324 (structure was padded due to alignment specifier)
                target_compile_options(${TARGET_NAME} ${SCOPE} "/wd4324")
            elseif(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX OR (CMAKE_CXX_COMPILER_ID MATCHES "Clang"))
                target_compile_options(${TARGET_NAME} ${SCOPE} "-Wall" "-Wextra" "-pedantic")
            endif()

        elseif(OPTION STREQUAL "fatal-errors")
            # every error is fatal; stop after reporting first error
            if(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
                target_compile_options(${TARGET_NAME} ${SCOPE} "-Wfatal-errors")
            elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
                target_compile_options(${TARGET_NAME} ${SCOPE} "-ferror-limit=1")
            endif()

        else()
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
        cmakeshift_target_compile_setting_(${TARGET_NAME} PRIVATE "${arg}")
    endforeach()
    foreach(arg IN LISTS SCOPE_INTERFACE)
        cmakeshift_target_compile_setting_(${TARGET_NAME} INTERFACE "${arg}")
    endforeach()
    foreach(arg IN LISTS SCOPE_PUBLIC)
        cmakeshift_target_compile_setting_(${TARGET_NAME} PUBLIC "${arg}")
    endforeach()
endfunction()
