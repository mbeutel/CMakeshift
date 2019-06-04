
# CMakeshift
# detail/Settings-Default.cmake
# Author: Moritz Beutel



list(APPEND _CMAKESHIFT_KNOWN_SETTINGS
    "cpu-architecture="
    "fp-model="
    "cuda-architecture="
    "cuda-gpu-code=")


function(_CMAKESHIFT_SETTINGS_ARCHITECTURE)

	# variables available from calling scope: SETTING, HAVE_<LANG>, PASSTHROUGH, VAL, TARGET_NAME, SCOPE, LB, RB

    if(SETTING STREQUAL "cpu-architecture")

        string(TOLOWER "${VAL}" ARCH)

        if(NOT ARCH STREQUAL "default" AND NOT ARCH STREQUAL "")
        
            # FMA3 is available starting with Haswell, which is also the first to support AVX2.
            if(ARCH STREQUAL "skylake" OR ARCH STREQUAL "skylake-server" OR ARCH STREQUAL "skylake-server-avx512" OR ARCH STREQUAL "knl")
                target_compile_definitions(${TARGET_NAME} ${SCOPE} "${LB}HAVE_FUSED_MULTIPLY_ADD=1${RB}")
            endif()
            if(ARCH STREQUAL "skylake-server-avx512" OR ARCH STREQUAL "knl")
                target_compile_definitions(${TARGET_NAME} ${SCOPE} "${LB}PREFER_AVX512=1${RB}")
            endif()

            if(MSVC)
                if(ARCH STREQUAL "penryn")
                    if(CMAKE_SIZEOF_VOID_P EQUAL 8) # compiling for x64
                        target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}/favor:INTEL64${RB}")
                    endif()
                elseif(ARCH STREQUAL "skylake" OR ARCH STREQUAL "skylake-server" OR ARCH STREQUAL "skylake-server-avx512")
                    target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}/arch:AVX2${RB}")
                    if(CMAKE_SIZEOF_VOID_P EQUAL 8) # compiling for x64
                        target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}/favor:INTEL64${RB}")
                    endif()
                elseif(ARCH STREQUAL "knl")
                    target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}/arch:AVX2${RB}" "${LB}${PASSTHROUGH}/favor:ATOM${RB}")
                else()
                    set(_SETTING_SET FALSE PARENT_SCOPE)
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
                    target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}${ARCHARG}sse4.1${RB}" "${LB}${PASSTHROUGH}${XARG}sse4.1${RB}")
                elseif(ARCH STREQUAL "skylake")
                    target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}${ARCHARG2}core-avx2${RB}" "${LB}${PASSTHROUGH}${XARG}core-avx2${RB}")
                elseif(ARCH STREQUAL "skylake-server")
                    target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}${ARCHARG2}core-avx2${RB}" "${LB}${PASSTHROUGH}${XARG}core-avx512${RB}")
                elseif(ARCH STREQUAL "skylake-server-avx512")
                    target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}${ARCHARG2}core-avx2${RB}" "${LB}${PASSTHROUGH}${XARG}core-avx512${RB}" "${LB}${PASSTHROUGH}${QARG}opt-zmm-usage${ASGN}high${RB}")
                elseif(ARCH STREQUAL "knl")
                    target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}${ARCHARG2}core-avx2${RB}" "${LB}${PASSTHROUGH}${XARG}mic-avx512${RB}")
                else()
                    set(_SETTING_SET FALSE PARENT_SCOPE)
                endif()
            elseif(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
                if(ARCH STREQUAL "penryn")
                    target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}-march=core2${RB}" "${LB}${PASSTHROUGH}-msse4.1${RB}")
                elseif(ARCH STREQUAL "skylake")
                    target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}-march=skylake${RB}")
                elseif(ARCH STREQUAL "skylake-server")
                    target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}-march=skylake-avx512${RB}")
                elseif(ARCH STREQUAL "skylake-server-avx512")
                    target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}-march=skylake-avx512${RB}" "${LB}${PASSTHROUGH}-mprefer-vector-width=512${RB}")
                elseif(ARCH STREQUAL "knl")
                    target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}-march=knl${RB}" "${LB}${PASSTHROUGH}-mprefer-vector-width=512${RB}")
                else()
                    set(_SETTING_SET FALSE PARENT_SCOPE)
                endif()
            elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
                if(ARCH STREQUAL "penryn")
                    target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}-march=penryn${RB}")
                elseif(ARCH STREQUAL "skylake")
                    target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}-march=skylake${RB}")
                elseif(ARCH STREQUAL "skylake-server")
                    target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}-march=skylake-avx512${RB}")
                elseif(ARCH STREQUAL "skylake-server-avx512")
                    target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}-march=skylake-avx512${RB}" "${LB}${PASSTHROUGH}-mprefer-vector-width=512${RB}")
                elseif(ARCH STREQUAL "knl")
                    target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}-march=knl${RB}" "${LB}${PASSTHROUGH}-mprefer-vector-width=512${RB}")
                else()
                    set(_SETTING_SET FALSE PARENT_SCOPE)
                endif()
            else()
                message(WARNING "cmakeshift_target_compile_settings(): Unknown compiler; cannot set target architecture")
            endif()

            if(NOT _SETTING_SET)
                message(SEND_ERROR "cmakeshift_target_compile_settings(): Unknown CPU architecture \"${ARCH}\"")
            endif()

        endif()

    elseif(SETTING STREQUAL "fp-model")

        string(TOLOWER "${VAL}" MODEL)

        if(NOT MODEL STREQUAL "" AND NOT MODEL STREQUAL "default")

			if(HAVE_CUDA)
				if(CMAKE_CUDA_COMPILER_ID MATCHES "NVIDIA")
					if(MODEL STREQUAL "strict" OR MODEL STREQUAL "consistent")
						target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}$<$<COMPILE_LANGUAGE:CUDA>:--fmad=false>${RB}") # do not fuse multiplications and additions
					elseif(MODEL STREQUAL "precise")
						# default behavior; nothing to do
					elseif(MODEL STREQUAL "fast")
						target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}$<$<COMPILE_LANGUAGE:CUDA>:--ftz=true>${RB}" "${LB}$<$<COMPILE_LANGUAGE:CUDA>:--prec-div=false${RB}" "${LB}$<$<COMPILE_LANGUAGE:CUDA>:--prec-sqrt=false>${RB}")
					elseif(MODEL STREQUAL "fastest")
						target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}$<$<COMPILE_LANGUAGE:CUDA>:--use_fast_math>${RB}") # implies everything in "fast" above
					else()
						set(_SETTING_SET FALSE PARENT_SCOPE)
					endif()
					
				else()
					message(FATAL_ERROR "cmakeshift_target_compile_settings(): Unknown CUDA compiler: CMAKE_CUDA_COMPILER_ID=${CMAKE_CUDA_COMPILER_ID}")
				endif()
			endif()

            if(MSVC)
                if(MODEL STREQUAL "strict" OR MODEL STREQUAL "consistent")
                    target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}/fp:strict${RB}")
                elseif(MODEL STREQUAL "precise")
                    target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}/fp:precise${RB}")
                elseif(MODEL STREQUAL "fast" OR MODEL STREQUAL "fastest")
                    target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}/fp:fast${RB}")
                else()
                    set(_SETTING_SET FALSE PARENT_SCOPE)
                endif()
            elseif(CMAKE_C_COMPILER MATCHES "icc.*$") # Intel compiler
                if(MODEL STREQUAL "strict" OR MODEL STREQUAL "consistent" OR MODEL STREQUAL "precise" OR MODEL STREQUAL "fast")
                    set(MODELARG ${MODEL})
                elseif(MODEL STREQUAL "fastest")
                    set(MODELARG "fast=2")
                else()
                    set(_SETTING_SET FALSE PARENT_SCOPE)
                endif()
                if(_SETTING_SET)
                    if(WIN32)
                        target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}/fp:${MODELARG}${RB}")
                    else()
                        target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}-fp-model${RB} ${LB}${MODELARG}${RB}") # TODO: does this work, or do we need two separate arguments?
                    endif()
                endif()
            elseif(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
                if(MODEL STREQUAL "strict" OR MODEL STREQUAL "consistent")
                    target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}-ffp-contract=off${RB}")
                elseif(MODEL STREQUAL "precise")
                    # default behavior; nothing to do
                elseif(MODEL STREQUAL "fast")
                    target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}-funsafe-math-optimizations${RB}")
                elseif(MODEL STREQUAL "fastest")
                    target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}-ffast-math${RB}")
                else()
                    set(_SETTING_SET FALSE PARENT_SCOPE)
                endif()
            elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
                if(MODEL STREQUAL "strict" OR MODEL STREQUAL "consistent" OR MODEL STREQUAL "precise")
                    # default behavior; nothing to do
                elseif(MODEL STREQUAL "fast" OR MODEL STREQUAL "fastest")
                    target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}${PASSTHROUGH}-ffast-math${RB}")
                else()
                    set(_SETTING_SET FALSE PARENT_SCOPE)
                endif()
            else()
                message(WARNING "cmakeshift_target_compile_settings(): Unknown compiler; cannot set floating-point model")
            endif()

            if(NOT _SETTING_SET)
                message(SEND_ERROR "cmakeshift_target_compile_settings(): Unknown floating-point model \"${MODEL}\"")
            endif()

        endif()
        
    elseif(SETTING STREQUAL "cuda-architecture")

        string(TOLOWER "${VAL}" ARCH)

        if(HAVE_CUDA AND NOT ARCH STREQUAL "" AND NOT ARCH STREQUAL "default")
			if(CMAKE_CUDA_COMPILER_ID MATCHES "NVIDIA")
				target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}$<$<COMPILE_LANGUAGE:CUDA>:--gpu-architecture=${ARCH}>${RB}")
			else()
				message(FATAL_ERROR "cmakeshift_target_compile_settings(): Unknown CUDA compiler: CMAKE_CUDA_COMPILER_ID=${CMAKE_CUDA_COMPILER_ID}")
			endif()
		endif()
        
    elseif(SETTING STREQUAL "cuda-gpu-code")

        string(TOLOWER "${VAL}" GPUCODE)

        if(HAVE_CUDA AND NOT GPUCODE STREQUAL "" AND NOT GPUCODE STREQUAL "default")
			if(CMAKE_CUDA_COMPILER_ID MATCHES "NVIDIA")
				target_compile_options(${TARGET_NAME} ${SCOPE} "${LB}$<$<COMPILE_LANGUAGE:CUDA>:--gpu-code=${GPUCODE}>${RB}")
			else()
				message(FATAL_ERROR "cmakeshift_target_compile_settings(): Unknown CUDA compiler: CMAKE_CUDA_COMPILER_ID=${CMAKE_CUDA_COMPILER_ID}")
			endif()
		endif()

    else()
        set(_SETTING_SET FALSE PARENT_SCOPE)
    endif()

endfunction()
