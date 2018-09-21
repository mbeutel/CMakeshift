
# CMakeshift
# SetTargetArchitecture.cmake
# Author: Moritz Beutel


# Define build options.
set(TARGET_ARCHITECTURE "Default" CACHE STRING "Set target architecture (default, penryn, skylake, skylake-server, skylake-server-avx512, knl)")


# Set the target machine architecture.
#
#     cmakeshift_set_target_architecture(<target>
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
function(CMAKESHIFT_SET_TARGET_ARCHITECTURE TARGETNAME)

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

    if(ARCH AND NOT (ARCH STREQUAL "default"))

        # FMA3 is available starting with Haswell, which is also the first to support AVX2.
        if(ARCH STREQUAL "skylake" OR ARCH STREQUAL "skylake-server" OR ARCH STREQUAL "skylake-server-avx512" OR ARCH STREQUAL "knl")
            target_compile_definitions(${TARGETNAME} PRIVATE HAVE_FUSED_MULTIPLY_ADD=1)
        endif()
        if(ARCH STREQUAL "skylake-server-avx512" OR ARCH STREQUAL "knl")
            target_compile_definitions(${TARGETNAME} PRIVATE PREFER_AVX512=1)
        endif()

        if(MSVC)
            if(ARCH STREQUAL "penryn")
                if(CMAKE_SIZEOF_VOID_P EQUAL 8) # compiling for x64
                    target_compile_options(${TARGETNAME} PRIVATE "/favor:INTEL64")
                endif()
            elseif(ARCH STREQUAL "skylake" OR ARCH STREQUAL "skylake-server" OR ARCH STREQUAL "skylake-server-avx512")
                target_compile_options(${TARGETNAME} PRIVATE "/arch:AVX2")
                if(CMAKE_SIZEOF_VOID_P EQUAL 8) # compiling for x64
                    target_compile_options(${TARGETNAME} PRIVATE "/favor:INTEL64")
                endif()
            elseif(ARCH STREQUAL "knl")
                target_compile_options(${TARGETNAME} PRIVATE "/arch:AVX2" "/favor:ATOM")
            else()
                message(SEND_ERROR "Unknown architecture '${ARCH}'")
            endif()
        elseif(CMAKE_C_COMPILER MATCHES "icc.*$") # Intel compiler
            if(WIN32)
                set(ARCHARG "/arch:")
                set(ARCHARG2 "/arch:")
                set(QARG "/Q")
                set(XARG "/Qx")
                set(ASGN ":")
            else()
                set(ARCHARG "-m")
                set(ARCHARG2 "-march=")
                set(QARG "-q")
                set(XARG "-x")
                set(ASGN "=")
            endif()
            if(ARCH STREQUAL "penryn")
                target_compile_options(${TARGETNAME} PRIVATE "${ARCHARG}sse4.1" "${XARG}sse4.1")
            elseif(ARCH STREQUAL "skylake")
                target_compile_options(${TARGETNAME} PRIVATE "${ARCHARG2}core-avx2" "${XARG}core-avx2")
            elseif(ARCH STREQUAL "skylake-server")
                target_compile_options(${TARGETNAME} PRIVATE "${ARCHARG2}core-avx2" "${XARG}core-avx512")
            elseif(ARCH STREQUAL "skylake-server-avx512")
                target_compile_options(${TARGETNAME} PRIVATE "${ARCHARG2}core-avx2" "${XARG}core-avx512" "${QARG}opt-zmm-usage${ASGN}high")
            elseif(ARCH STREQUAL "knl")
                target_compile_options(${TARGETNAME} PRIVATE "${ARCHARG2}core-avx2" "${XARG}mic-avx512")
            else()
                message(SEND_ERROR "Unknown architecture '${ARCH}'")
            endif()
        elseif(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
            if(ARCH STREQUAL "penryn")
                target_compile_options(${TARGETNAME} PRIVATE "-march=core2" "-msse4.1")
            elseif(ARCH STREQUAL "skylake")
                target_compile_options(${TARGETNAME} PRIVATE "-march=skylake")
            elseif(ARCH STREQUAL "skylake-server")
                target_compile_options(${TARGETNAME} PRIVATE "-march=skylake-avx512")
            elseif(ARCH STREQUAL "skylake-server-avx512")
                target_compile_options(${TARGETNAME} PRIVATE "-march=skylake-avx512" "-mprefer-vector-width=512")
            elseif(ARCH STREQUAL "knl")
                target_compile_options(${TARGETNAME} PRIVATE "-march=knl" "-mprefer-vector-width=512")
            else()
                message(SEND_ERROR "Unknown architecture '${ARCH}'")
            endif()
        else()
            message(SEND_ERROR "Unknown compiler; cannot set target architecture")
        endif()
    endif()
endfunction()



# Permits or suppresses the fusing of multiplication and addition operations for the specified target.
#
#     cmakeshift_set_target_contract_multiply_add(<target> ON|OFF)
#
function(CMAKESHIFT_SET_TARGET_CONTRACT_MULTIPLY_ADD TARGETNAME CONTRACT)
    if(MSVC)
        # VC++ defaults to "/fp:precise", which does not permit FMA fusing
        if(CONTRACT)
            target_compile_options(${TARGETNAME} PRIVATE "/fp:fast")
        endif()
    elseif(CMAKE_C_COMPILER MATCHES "icc.*$") # Intel compiler
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
