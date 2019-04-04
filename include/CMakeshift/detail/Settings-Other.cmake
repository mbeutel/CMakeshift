
# CMakeshift
# detail/Settings-Other.cmake
# Author: Moritz Beutel



list(APPEND _CMAKESHIFT_KNOWN_SETTINGS
    "hidden-inline")


function(_CMAKESHIFT_SETTINGS_OTHER SETTING VAL TARGET_NAME SCOPE LB RB)

    if(SETTING STREQUAL "hidden-inline")
        message(DEPRECATION "cmakeshift_target_compile_settings(): the setting \"hidden-inline\" is deprecated; instead set the target property \"VISIBILITY_INLINES_HIDDEN\" directly")

        # don't export inline functions
        set_target_properties(${TARGET_NAME} PROPERTIES VISIBILITY_INLINES_HIDDEN TRUE)

    else()
        set(_SETTING_SET FALSE PARENT_SCOPE)
    endif()

endfunction()
