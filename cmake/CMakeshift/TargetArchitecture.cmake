
# CMakeshift
# TargetArchitecture.cmake
# Author: Moritz Beutel


# This variable is no longer defined to avoid exposing it in cache editors, but it is still respected by cmakeshift_target_architecture().
#set(TARGET_ARCHITECTURE "Default" CACHE STRING "Set target architecture (default, penryn, skylake, skylake-server, skylake-server-avx512, knl)")


# Define build options.
set(CPU_TARGET_ARCHITECTURE "" CACHE STRING "Set CPU target architecture (default, penryn, skylake, skylake-server, skylake-server-avx512, knl)")

get_property(_CMAKESHIFT_ENABLED_LANGUAGES GLOBAL PROPERTY ENABLED_LANGUAGES)
if(CUDA IN_LIST _CMAKESHIFT_ENABLED_LANGUAGES)
    set(CUDA_TARGET_ARCHITECTURE "" CACHE STRING "Set CUDA target architecture (e.g. sm_61, compute_61)")
    set(CUDA_GPU_CODE "" CACHE STRING "Set CUDA GPU code to generate (e.g. sm_61)")
endif()


include(CMakeshift/TargetCompileSettings)


# Set the target machine architecture.
#
#     cmakeshift_target_architecture(<target>
#         [ARCH <architecture>])
#
# Supported values for ARCH:
#
#     default                   don't generate architecture-specific code
#     penryn                    generate code for Intel Core 2 Refresh "Penryn"
#     skylake                   generate code for Intel Core/Xeon "Skylake"
#     skylake-server            generate code for Intel Core/Xeon "Skylake Server"
#     skylake-server-avx512     generate code for Intel Core/Xeon "Skylake Server", prefer AVX-512 instructions
#     knl                       generate code for Intel Xeon Phi "Knights Landing"
#
# If ARCH is not specified or empty, the TARGET_ARCHITECTURE cache variable is used.
#
function(CMAKESHIFT_TARGET_ARCHITECTURE TARGETNAME)

    message(DEPRECATION "cmakeshift_target_architecture() is deprecated; instead use cmakeshift_target_compile_settings() with the \"cpu-architecture=<arch>\" setting.")

    # Parse arguments.
    set(options "")
    set(oneValueArgs ARCH)
    set(multiValueArgs "")
    cmake_parse_arguments(PARSE_ARGV 1 "SCOPE" "${options}" "${oneValueArgs}" "${multiValueArgs}")
    if(SCOPE_UNPARSED_ARGUMENTS)
        message(SEND_ERROR "Invalid argument keywords \"${SCOPE_UNPARSED_ARGUMENTS}\"")
    endif()
    if(SCOPE_ARCH)
        string(TOLOWER "${SCOPE_ARCH}" ARCH)
    else()
        string(TOLOWER "${TARGET_ARCHITECTURE}" ARCH)
    endif()

    cmakeshift_target_compile_settings(${TARGETNAME} PRIVATE "cpu-architecture=${ARCH}")

endfunction()



# Permits or suppresses the fusing of multiplication and addition operations for the specified target.
#
#     cmakeshift_target_contract_multiply_add(<target> ON|OFF)
#
function(CMAKESHIFT_TARGET_CONTRACT_MULTIPLY_ADD TARGETNAME CONTRACT)

    message(DEPRECATION "cmakeshift_target_contract_multiply_add() is deprecated; instead use cmakeshift_target_compile_settings() with \"fp-model=<model>\".")

    if(MSVC)
        # VC++ defaults to "/fp:precise", which does not permit FMA fusing
        if(CONTRACT)
            target_compile_options(${TARGETNAME} PRIVATE "/fp:fast")
        endif()
    elseif(CMAKE_C_COMPILER MATCHES "icc.*$" OR CMAKE_CXX_COMPILER MATCHES "icpc.*$") # Intel compiler
        # ICC defaults to "-fp-model fast=1" which permits FMA fusing, as does "-fp-model precise".
        if(NOT CONTRACT)
            if(WIN32)
                target_compile_options(${TARGETNAME} PRIVATE "/fp:strict")
            else()
                target_compile_options(${TARGETNAME} PRIVATE "-fp-model" "strict")
            endif()
        endif()
    elseif(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX OR (CMAKE_CXX_COMPILER_ID MATCHES "Clang"))
        if(CONTRACT)
            target_compile_options(${TARGETNAME} PRIVATE "-mfma" "-ffp-contract=fast")
        else()
            target_compile_options(${TARGETNAME} PRIVATE "-ffp-contract=off")
        endif()
    else()
        message(SEND_ERROR "Unknown compiler; cannot set multiply/add contraction")
    endif()
endfunction()
