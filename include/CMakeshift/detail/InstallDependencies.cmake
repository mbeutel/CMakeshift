
# CMakeshift
# InstallDependencies.cmake
# Author: Moritz Beutel

function(_cmakeshift_install_targets)

    set(_TARGET_TYPES "ARCHIVE" "LIBRARY" "RUNTIME" "OBJECTS" "FRAMEWORK" "BUNDLE" "PRIVATE_HEADER" "PUBLIC_HEADER" "RESOURCE" "INCLUDES")

    # Parse arguments to find list of targets and runtime destination for given targets.
    set(INDEX 0)
    set(TARGETS "")
    set(BEYOND_TARGETS FALSE)
    set(TARGET_TYPE_IS_RUNTIME FALSE)
    set(NEXT_ARG_IS_DESTINATION FALSE)
    set(RUNTIME_DESTINATION "${CMAKE_INSTALL_BINDIR}") # default value
    while(INDEX LESS ${ARGC})
        set(_ARG ${ARGV${INDEX}})
        
        if(NEXT_ARG_IS_DESTINATION)
            if(TARGET_TYPE_IS_RUNTIME)
                set(RUNTIME_DESTINATION "${_ARG}")
            endif()
            set(NEXT_ARG_IS_DESTINATION FALSE)
        else()
            if(_ARG IN_LIST _TARGET_TYPES)
                set(BEYOND_TARGETS TRUE)
                if(_ARG STREQUAL "RUNTIME")
                    set(TARGET_TYPE_IS_RUNTIME TRUE)
                else()
                    set(TARGET_TYPE_IS_RUNTIME FALSE)
                endif()
            elseif(NOT BEYOND_TARGETS AND _ARG STREQUAL "EXPORT")
                set(BEYOND_TARGETS TRUE)
            endif()
            
            if(BEYOND_TARGETS)
                if(_ARG STREQUAL "DESTINATION")
                    set(NEXT_ARG_IS_DESTINATION TRUE)
                endif()
            else()
                list(APPEND TARGETS "${_ARG}")
            endif()
        endif()
        
        math(EXPR INDEX "${INDEX}+1")
    endwhile()
    
    if(WIN32)
        if(VCPKG_TOOLCHAIN)
            # When building with Vcpkg, we use its support for app-local deployment to copy DLL dependencies to the runtime output directory.
            foreach(TARGET IN LISTS TARGETS)
                get_target_property(TARGET_TYPE ${TARGET} TYPE)
                if(TARGET_TYPE STREQUAL EXECUTABLE)
                    add_custom_target(${TARGET}_InstallDLLs
                        COMMAND
                        _TARGET_OUTPUT_DIR
                            PowerShell -NoProfile -ExecutionPolicy Bypass -file "${_VCPKG_TOOLCHAIN_DIR}/msbuild/applocal.ps1"
                                -targetBinary "$<TARGET_FILE:${TARGET}>"
                                -installedDir "${CMAKE_INSTALL_PREFIX}/${RUNTIME_DESTINATION}"
                                -OutVariable out)
                    set_target_properties(${TARGET}_InstallDLLs
                        PROPERTIES
                            EXCLUDE_FROM_ALL TRUE)
                    if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.14)
                        install(CODE
                            "execute_process(COMMAND \"${CMAKE_COMMAND}\" --build . --target ${TARGET}_InstallDLLs --config $<CONFIG>)")
                    elseif(NOT GENERATOR_IS_MULTI_CONFIG)
                        install(CODE
                            "execute_process(COMMAND \"${CMAKE_COMMAND}\" --build . --target ${TARGET}_InstallDLLs --config ${CMAKE_BUILD_TYPE})")
                    else()
                        message(WARNING "[CMakeshift] CMake 3.14 or higher is needed for app-local runtime dependency installation")
                    endif()
                endif()
            endforeach()
        endif()
    endif()

endfunction()
