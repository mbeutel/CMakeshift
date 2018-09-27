
# CMakeshift
# SetTargetArchitecture.cmake
# Author: Moritz Beutel


message(DEPRECATION "CMakeshift/SetTargetArchitecture is deprecated; include CMakeshift/TargetArchitecture instead.")

include(${CMAKE_CURRENT_LIST_DIR}/TargetArchitecture.cmake)

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
function(CMAKESHIFT_SET_TARGET_ARCHITECTURE)

    message(DEPRECATION "cmakeshift_set_target_architecture() is deprecated; use cmakeshift_target_architecture() instead.")

    cmakeshift_target_architecture(${ARGN})
endfunction()



# Permits or suppresses the fusing of multiplication and addition operations for the specified target.
#
#     cmakeshift_set_target_contract_multiply_add(<target> ON|OFF)
#
function(CMAKESHIFT_SET_TARGET_CONTRACT_MULTIPLY_ADD)

    message(DEPRECATION "cmakeshift_set_target_contract_multiply_add() is deprecated; use cmakeshift_target_contract_multiply_add() instead.")

    cmakeshift_target_contract_multiply_add(${ARGN})
endfunction()
