
# CMakeshift
# detail/Settings-RuntimeChecks.cmake
# Author: Moritz Beutel



list(APPEND _CMAKESHIFT_KNOWN_CUMULATIVE_SETTINGS
    "runtime-checks")

list(APPEND _CMAKESHIFT_KNOWN_SETTINGS
    "runtime-checks-stack"
    "runtime-checks-asan"
    "runtime-checks-ubsan"
    "debug-stdlib")


function(_CMAKESHIFT_SETTINGS_RUNTIME_CHECKS SETTING VAL TARGET_NAME SCOPE LB RB)

    if(OPTION STREQUAL "runtime-checks-stack")
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
                message(WARNING "Not enabling UBSan for target \"${TARGET_NAME}\" because it can cause linker errors in Clang 6 and 7.")
                set(_SETTING_SET FALSE)
            elseif("debug-stdlib" IN_LIST _CURRENT${_INTERFACE}_SETTINGS)
                message(WARNING "Not enabling UBSan for target \"${TARGET_NAME}\" because it is known to raise issues in libc++ debugging code.")
                set(_SETTING_SET FALSE)
            else()
                target_compile_options(${TARGET_NAME} PRIVATE "${LB}-fsanitize=undefined${RB}")
                target_link_libraries(${TARGET_NAME} PRIVATE "${LB}-fsanitize=undefined${RB}")
            endif()
        endif()

    elseif(OPTION STREQUAL "debug-stdlib")
        if(MSVC)
            # enable checked iterators (not necessary in debug builds because these enable debug iterators by default, which are a superset of checked iterators)
            target_compile_definitions(${TARGET_NAME} PRIVATE "${LB}$<$<NOT:$<CONFIG:Debug>>:_ITERATOR_DEBUG_LEVEL=1>${RB}")

        elseif(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
            # enable libstdc++ debug mode
            target_compile_definitions(${TARGET_NAME} PRIVATE "${LB}$<$<CONFIG:Debug>:_GLIBCXX_DEBUG>${RB}")

        elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
            if("runtime-checks-ubsan" IN_LIST _CURRENT${_INTERFACE}_SETTINGS)
                message(WARNING "Not enabling standard library debug mode for target \"${TARGET}\" because it uses UBSan, which is known to raise issues in libc++ debugging code.")
                set(_SETTING_SET FALSE)
            else()
                # enable libc++ debug mode
                target_compile_definitions(${TARGET_NAME} PRIVATE "${LB}$<IF:$<CONFIG:Debug>,_LIBCPP_DEBUG=1,_LIBCPP_DEBUG=0>${RB}")
            endif()
        endif()
    
    else()
        set(_SETTING_SET FALSE PARENT_SCOPE)
    endif()

endfunction()
