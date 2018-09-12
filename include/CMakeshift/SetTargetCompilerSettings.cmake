
# CMakeshift
# SetTargetCompilerSettings.cmake
# Author: Moritz Beutel


# Set known compile options for the target. Supported options:
#
#     default                   some default options everyone can agree on (conformant behavior, debugging convenience, etc.)
#     pedantic                  increase warning level
#
function(CMAKESHIFT_SET_TARGET_COMPILER_SETTINGS TARGET_NAME)

    function(CMAKESHIFT_UPDATE_CACHE_VARIABLE_ VAR_NAME VALUE)
        get_property(HELP_STRING CACHE ${VAR_NAME} PROPERTY HELPSTRING)
        get_property(VAR_TYPE CACHE ${VAR_NAME} PROPERTY TYPE)
        set(${VAR_NAME} ${VALUE} CACHE ${VAR_TYPE} "${HELP_STRING}" FORCE)
    endfunction()

    function(CMAKESHIFT_SET_TARGET_COMPILER_SETTING_ TARGET_NAME SCOPE OPTION0)
        string(TOLOWER "${OPTION0}" OPTION)
        if(OPTION STREQUAL "default")
            # default options everyone can agree on
            if(MSVC)
                # enable permissive mode (prefer already rejuvenated parts of compiler for better conformance)
                target_compile_options(${TARGET_NAME} ${SCOPE} "/permissive-")

                # enable Just My Code for debugging convenience
                target_compile_options(${TARGET_NAME} ${SCOPE} "/JMC")

                # make `volatile` behave as specified by the language standard, as opposed to the quasi-atomic semantics VC++ implements by default
                target_compile_options(${TARGET_NAME} ${SCOPE} "/volatile:iso")
            endif()

        elseif(OPTION STREQUAL "pedantic")
            # highest sensible level for warnings and diagnostics
            if(MSVC)
                # remove "/Wx" from CMAKE_CXX_FLAGS if present, as VC++ doesn't tolerate more than one "/Wx" flag
                if(CMAKE_CXX_FLAGS MATCHES "/W[0-4]")
                    string(REGEX REPLACE "/W[0-4]" "" CMAKE_CXX_FLAGS_NEW "${CMAKE_CXX_FLAGS}")
                    cmakeshift_update_cache_variable_(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS_NEW}")
                endif()
                target_compile_options(${TARGET_NAME} ${SCOPE} "/W4")
            elseif(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX OR (CMAKE_CXX_COMPILER_ID MATCHES "Clang"))
                target_compile_options(${TARGET_NAME} ${SCOPE} "-Wall -Wextra -pedantic")
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
        cmakeshift_set_target_compiler_setting_(${TARGET_NAME} PRIVATE "${arg}")
    endforeach()
    foreach(arg IN LISTS SCOPE_INTERFACE)
        cmakeshift_set_target_compiler_setting_(${TARGET_NAME} INTERFACE "${arg}")
    endforeach()
    foreach(arg IN LISTS SCOPE_PUBLIC)
        cmakeshift_set_target_compiler_setting_(${TARGET_NAME} PUBLIC "${arg}")
    endforeach()
endfunction()
