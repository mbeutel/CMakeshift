
# CMakeshift script library
# Author: Moritz Beutel
# CMakeshift scripts


cmake_minimum_required(VERSION 3.12)


# CMakeshift is just a CMake script library, so it doesn't define targets.


# installation: CMake modules
install(
    DIRECTORY "${PROJECT_SOURCE_DIR}/include/"
    DESTINATION "share/cmake/${PROJECT_NAME}-${PROJECT_VERSION}/cmake")
