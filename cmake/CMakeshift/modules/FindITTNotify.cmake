
#.rst:
# FindITTNotify
# -------------
#
# Find the headers and library files for the ITTNotify API.
#
# Look for the files in the ITTNotify_ROOT directory and in the root directory of the
# VTune installation in the path (if any).
#
# This will define the following variables::
#
#   ITTNOTIFY_FOUND      - True if the ITTNotify API headers and libraries were found
#
# and the following imported targets::
#
#   ITTNotify::ITTNotify - The ITTNotify library
#
# The following macros can be defined prior to using this find module:
#
#   ITTNOTIFY_ROOT       - Optional path where to search for ITTNotify


# Look in the VTune root directory if we can find it.
find_program(_ITTNOTIFY_AMPLXE_CL
    NAMES amplxe-cl)
if(_ITTNOTIFY_AMPLXE_CL)
    get_filename_component(_AMPLXE_ROOT ${_ITTNOTIFY_AMPLXE_CL} DIRECTORY) # <root>/lib[64]
    get_filename_component(_AMPLXE_ROOT ${_AMPLXE_ROOT} DIRECTORY) # <root>
else()
    set(_AMPLXE_ROOT "")
endif()

find_path(ITTNOTIFY_INCLUDE_DIR
    NAMES ittnotify.h
    HINTS ${_AMPLXE_ROOT}
    PATH_SUFFIXES "include")
find_library(ITTNOTIFY_LIBRARY
    NAMES ittnotify
    HINTS ${_AMPLXE_ROOT}
    PATH_SUFFIXES "lib" "lib64")

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(ITTNotify
    REQUIRED_VARS ITTNOTIFY_INCLUDE_DIR ITTNOTIFY_LIBRARY)

if(ITTNotify_FOUND)
    # Define a target only if none has been defined yet.
    if(NOT TARGET ITTNotify::ITTNotify)
        add_library(ITTNotify::ITTNotify STATIC IMPORTED)
        set_target_properties(ITTNotify::ITTNotify PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES ${ITTNOTIFY_INCLUDE_DIR}
            IMPORTED_LOCATION             ${ITTNOTIFY_LIBRARY})
        if(NOT WIN32)
            set_target_properties(ITTNotify::ITTNotify PROPERTIES
                INTERFACE_LINK_LIBRARIES dl)
        endif()
    endif()
endif()

mark_as_advanced(ITTNOTIFY_INCLUDE_DIR ITTNOTIFY_LIBRARY _ITTNOTIFY_AMPLXE_CL)

