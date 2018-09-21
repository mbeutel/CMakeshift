
# CMakeshift
# InstallSimpleLibraryPackage.cmake
# Author: Moritz Beutel


# Define build options.
option(EXPORT_BUILD_DIR "Export build directory using CMake (enables external use without install)" OFF)


# Get the CMakeshift script include directory.
get_filename_component(CMAKESHIFT_SCRIPT_DIR "${CMAKE_CURRENT_LIST_FILE}" DIRECTORY)
get_filename_component(CMAKESHIFT_SCRIPT_DIR "${CMAKESHIFT_SCRIPT_DIR}" DIRECTORY)


# Install library package with the given exports.
#
#     cmakeshift_install_simple_library_package(
#         [PROJECT <project-name>]
#         [EXPORT <export>]
#         VERSION_COMPATIBILITY <AnyNewerVersion|ExactVersion|SameMajorVersion|SameMinorVersion>
#         CONFIG_TEMPLATE <filename>)
#
function(CMAKESHIFT_INSTALL_SIMPLE_LIBRARY_PACKAGE)

    # Parse arguments.
    set(options "")
    set(oneValueArgs PROJECT VERSION_COMPATIBILITY CONFIG_TEMPLATE EXPORT)
    set(multiValueArgs "")
    cmake_parse_arguments(PARSE_ARGV 0 "SCOPE" "${options}" "${oneValueArgs}" "${multiValueArgs}")
    if(SCOPE_UNPARSED_ARGUMENTS)
        message(SEND_ERROR "Invalid argument keywords \"${SCOPE_UNPARSED_ARGUMENTS}\"")
    endif()
    if(NOT SCOPE_VERSION_COMPATIBILITY)
        message(SEND_ERROR "VERSION_COMPATIBILITY not set (expected AnyNewerVersion, ExactVersion, SameMajorVersion, or SameMinorVersion)")
    endif()
    if(NOT SCOPE_CONFIG_TEMPLATE)
        message(SEND_ERROR "CONFIG_TEMPLATE file not set")
    endif()
    if(NOT SCOPE_PROJECT)
        set(SCOPE_PROJECT ${PROJECT_NAME})
    endif()

    set(SCOPE_PROJECT_VERSION ${${SCOPE_PROJECT}_VERSION})
    set(SCOPE_PROJECT_BINARY_DIR "${${SCOPE_PROJECT}_BINARY_DIR}")


    # Generate package version file.
    include(CMakePackageConfigHelpers)
    write_basic_package_version_file("${SCOPE_PROJECT_BINARY_DIR}/${SCOPE_PROJECT}ConfigVersion-generic.cmake"
        VERSION ${SCOPE_PROJECT_VERSION}
        COMPATIBILITY ${SCOPE_VERSION_COMPATIBILITY})


    # Install method #1: Put library in CMAKE_INSTALL_PREFIX, i.e. /usr/local or equivalent.

    # Determine the install path for the *Config.cmake configuration file relative to CMAKE_INSTALL_PREFIX.
    set(RELATIVE_CONFIG_INSTALL_DIR "share/cmake/${PROJECT_NAME}-${PROJECT_VERSION}")

    # This "exports" for installation all targets which have been put into the export set "*Export". This generates
    # a *Targets.cmake file which, when read in by a client project as part of find_package(*), creates imported
    # library targets for the project (with dependency relations) which can be used in target_link_libraries()
    # calls in the client project.
    if(SCOPE_EXPORT)
        install(
            EXPORT ${SCOPE_EXPORT}
            DESTINATION "${RELATIVE_CONFIG_INSTALL_DIR}"
            NAMESPACE "${SCOPE_PROJECT}::"
            FILE ${SCOPE_PROJECT}Targets.cmake)
    endif()

    # Configure a *Config.cmake file for an installed version of the package from the template, reflecting the
    # current build options.
    # The "-install" suffix is necessary to distinguish the install version from the exported version, which must
    # be named *Config.cmake in PROJECT_BINARY_DIR to be detected. The suffix is removed when it is installed.
    set(SETUP_PACKAGE_CONFIG_FOR_INSTALLATION TRUE)
    configure_file("${SCOPE_CONFIG_TEMPLATE}"
        "${SCOPE_PROJECT_BINARY_DIR}/${SCOPE_PROJECT}Config-install.cmake" @ONLY)

    # Install the configuration files into the same directory as the autogenerated *Targets.cmake file.
    install(
        FILES "${SCOPE_PROJECT_BINARY_DIR}/${SCOPE_PROJECT}Config-install.cmake"
        RENAME "${SCOPE_PROJECT}Config.cmake"
        DESTINATION "${RELATIVE_CONFIG_INSTALL_DIR}")
    install(
        FILES "${SCOPE_PROJECT_BINARY_DIR}/${SCOPE_PROJECT}ConfigVersion-generic.cmake"
        RENAME "${SCOPE_PROJECT}ConfigVersion.cmake"
        DESTINATION "${RELATIVE_CONFIG_INSTALL_DIR}")


    # Install method #2: Put package build directory into local CMake registry. This allows the detection and use
    # of the package without requiring that it be installed.

    if(EXPORT_BUILD_DIR AND NOT CMAKE_EXPORT_NO_PACKAGE_REGISTRY)
        message("-- Exporting ${PROJECT_NAME} build directory to local CMake package registry.")
    
        # Analogously to install(EXPORT ...), export the targets from the build directory to a *Targets.cmake file.
        if(SCOPE_EXPORT)
            export(
                EXPORT ${SCOPE_EXPORT}
                NAMESPACE "${SCOPE_PROJECT}::"
                FILE "${SCOPE_PROJECT_BINARY_DIR}/${SCOPE_PROJECT}Targets.cmake")
        endif()

        # Export the project build directory as a package into the local CMake package registry.
        export(
            PACKAGE ${SCOPE_PROJECT})
    
        # Configure a *ConfigVersion.cmake file which includes the generic version checking file generated above
        # and additionally checks that build configurations match when referencing exported build directories when
        # not using a multi-config generator.
        configure_file("${CMAKESHIFT_SCRIPT_DIR}/CMakeshift/templates/ConfigVersion-BuildType.cmake.in"
            "${SCOPE_PROJECT_BINARY_DIR}/${SCOPE_PROJECT}ConfigVersion.cmake" @ONLY)
        
        # Configure a *Config.cmake file for the export of the build directory from the template, reflecting the
        # current build options.
        set(SETUP_PACKAGE_CONFIG_FOR_INSTALLATION FALSE)
        configure_file("${SCOPE_CONFIG_TEMPLATE}"
            "${SCOPE_PROJECT_BINARY_DIR}/${SCOPE_PROJECT}Config.cmake" @ONLY)
    endif()

endfunction()
