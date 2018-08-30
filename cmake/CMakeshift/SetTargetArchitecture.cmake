
# CMakeshift
# SetTargetArchitecture.cmake
# Author: Moritz Beutel


# Set the target machine architecture. Supported values for ARCH:
# 
#     "Default"                 don't generate architecture-specific code
#     "Penryn"                  generate code for Intel Core 2 Refresh "Penryn"
#     "Skylake"                 generate code for Intel Core/Xeon "Skylake"
#     "Skylake-Server"          generate code for Intel Core/Xeon "Skylake Server"
#     "Skylake-Server-AVX512"   generate code for Intel Core/Xeon "Skylake Server", prefer AVX-512 instructions
#     "KNL"                     generate code for Intel Xeon Phi "Knights Landing"
function(CMAKESHIFT_SET_TARGET_ARCHITECTURE TARGETNAME ARCH)
    string(TOLOWER "${ARCH}" ARCH_LOWERCASE)
    if(ARCH AND NOT (ARCH_LOWERCASE STREQUAL "default"))

        # FMA3 is available starting with Haswell, which is also the first to support AVX2.
        if(ARCH_LOWERCASE STREQUAL "skylake" OR ARCH_LOWERCASE STREQUAL "skylake-server" OR ARCH_LOWERCASE STREQUAL "skylake-server-avx512" OR ARCH_LOWERCASE STREQUAL "knl")
            target_compile_definitions(${TARGETNAME} PRIVATE HAVE_FUSED_MULTIPLY_ADD=1)
        endif()
        if(ARCH_LOWERCASE STREQUAL "skylake-server-avx512" OR ARCH_LOWERCASE STREQUAL "knl")
            target_compile_definitions(${TARGETNAME} PRIVATE PREFER_AVX512=1)
        endif()

        if(MSVC)
            if(ARCH_LOWERCASE STREQUAL "penryn")
                if(CMAKE_SIZEOF_VOID_P EQUAL 8) # compiling for x64
                    target_compile_options(${TARGETNAME} PRIVATE "/favor:INTEL64")
                endif()
            elseif(ARCH_LOWERCASE STREQUAL "skylake" OR ARCH_LOWERCASE STREQUAL "skylake-server" OR ARCH_LOWERCASE STREQUAL "skylake-server-avx512")
                target_compile_options(${TARGETNAME} PRIVATE "/arch:AVX2")
                if(CMAKE_SIZEOF_VOID_P EQUAL 8) # compiling for x64
                    target_compile_options(${TARGETNAME} PRIVATE "/favor:INTEL64")
                endif()
            elseif(ARCH_LOWERCASE STREQUAL "knl")
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
            if(ARCH_LOWERCASE STREQUAL "penryn")
                target_compile_options(${TARGETNAME} PRIVATE "${ARCHARG}sse4.1" "${XARG}sse4.1")
            elseif(ARCH_LOWERCASE STREQUAL "skylake")
                target_compile_options(${TARGETNAME} PRIVATE "${ARCHARG2}core-avx2" "${XARG}code-avx2")
            elseif(ARCH_LOWERCASE STREQUAL "skylake-server")
                target_compile_options(${TARGETNAME} PRIVATE "${ARCHARG2}core-avx2" "${XARG}code-avx512")
            elseif(ARCH_LOWERCASE STREQUAL "skylake-server-avx512")
                target_compile_options(${TARGETNAME} PRIVATE "${ARCHARG2}core-avx2" "${XARG}code-avx512" "${QARG}opt-zmm-usage${ASGN}high")
            elseif(ARCH_LOWERCASE STREQUAL "knl")
                target_compile_options(${TARGETNAME} PRIVATE "${ARCHARG2}core-avx2" "${XARG}mic-avx512")
            else()
                message(SEND_ERROR "Unknown architecture '${ARCH}'")
            endif()
        elseif(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
            if(ARCH_LOWERCASE STREQUAL "penryn")
                target_compile_options(${TARGETNAME} PRIVATE "-march=core2" "-msse4.1")
            elseif(ARCH_LOWERCASE STREQUAL "skylake")
                target_compile_options(${TARGETNAME} PRIVATE "-march=skylake")
            elseif(ARCH_LOWERCASE STREQUAL "skylake-server")
                target_compile_options(${TARGETNAME} PRIVATE "-march=skylake-avx512")
            elseif(ARCH_LOWERCASE STREQUAL "skylake-server-avx512")
                target_compile_options(${TARGETNAME} PRIVATE "-march=skylake-avx512" "-mprefer-vector-width=512")
            elseif(ARCH_LOWERCASE STREQUAL "knl")
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
function(CMAKESHIFT_SET_TARGET_CONTRACT_MULTIPLY_ADD TARGETNAME CONTRACT)
    string(TOLOWER "${ARCH}" ARCH_LOWERCASE)
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
