
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


function(_CMAKESHIFT_SETTINGS_RUNTIME_CHECKS)

	# variables available from calling scope: SETTING, HAVE_<LANG>, PASSTHROUGH, VAL, TARGET_NAME, SCOPE, LB, RB

    if(SETTING STREQUAL "runtime-checks-stack")
        if(MSVC)
            # VC++ already enables stack frame run-time error checking and detection of uninitialized values by default in debug builds

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

        if(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
            # enable stack protector
            target_compile_options(${TARGET_NAME} PRIVATE "${LB}${PASSTHROUGH}-fstack-protector${RB}")
        endif()

    elseif(SETTING STREQUAL "runtime-checks-asan")
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
                        target_sources(${TARGET_NAME} PRIVATE "${CMAKESHIFT_SCRIPT_DIR}/CMakeshift/detail/CMakeshift_AddressSanitizer_CUDA_workaround.c")
                    elseif(HAVE_CXX)
                        target_sources(${TARGET_NAME} PRIVATE "${CMAKESHIFT_SCRIPT_DIR}/CMakeshift/detail/CMakeshift_AddressSanitizer_CUDA_workaround.cpp")
                    else() # HAVE_CUDA
                        target_sources(${TARGET_NAME} PRIVATE "${CMAKESHIFT_SCRIPT_DIR}/CMakeshift/detail/CMakeshift_AddressSanitizer_CUDA_workaround.cu")
                    endif()
                endif()
            endif()
        endif()

    elseif(SETTING STREQUAL "runtime-checks-ubsan")
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
        endif()

    elseif(SETTING STREQUAL "debug-stdlib")
        if(MSVC)
            # enable checked iterators (not necessary in debug builds because these enable debug iterators by default, which are a superset of checked iterators)
            target_compile_definitions(${TARGET_NAME} PRIVATE "${LB}$<$<NOT:$<CONFIG:Debug>>:_ITERATOR_DEBUG_LEVEL=1>${RB}")

        elseif(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
            # enable libstdc++ debug mode
            target_compile_definitions(${TARGET_NAME} PRIVATE "${LB}$<$<CONFIG:Debug>:_GLIBCXX_DEBUG>${RB}")

        elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
            if("runtime-checks-ubsan" IN_LIST _CURRENT${_INTERFACE}_SETTINGS)
                message(WARNING "cmakeshift_target_compile_settings(): Not enabling standard library debug mode for target \"${TARGET}\" because it uses UBSan, which is known to raise issues in libc++ debugging code.")
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
