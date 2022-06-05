#!/bin/bash
# NOTE: This script builds a target C/C++ library using CMake as a shared library (.dll/.so/.dylib) for the purposes of P/Invoke with C#.
# INPUT:
#   $1: The path of the directory which contains the C/C++ CMakeLists.txt file.
#   $2: The path of the directory which will contain the output .dll/.so/.dylib. The directory is created if it does not already exist.
#   $3: The name of the library for platform invoke (P/Invoke) with C#.
#   $4: The target operating system to build the shared library for. Possible values are "host", "windows", "linux", "macos".
#   $5: The target architecture to build the shared library for. Possible values are "default", "x86_64", "arm64".
#   $6: Any additional CMake arguments.
# OUTPUT: The built shared library if successful, or nothing upon first failure.

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
. $DIR/input.sh
. $DIR/core.sh

printf "'$0': Validating input...\n\t1=$1\n\t2=$2\n\t3=$3\n\t4=$4\n\t5=$5\n\t6=$6\n"

TARGET_BUILD_INPUT_DIRECTORY_PATH=`get_input_directory_path "$1"`
if [[ ! -d "$TARGET_BUILD_INPUT_DIRECTORY_PATH" ]]; then
    echo "Error: The input directory does not exist or does not contain a 'CMakeLists.txt' file: '$1'"
    exit 1
fi

TARGET_BUILD_OUTPUT_DIRECTORY_PATH=`get_output_directory_path "$2"`
if [[ ! -d "$TARGET_BUILD_OUTPUT_DIRECTORY_PATH" ]]; then
    echo "Error: The output directory does not exist or could not be created: '$2'."
    exit 1
fi

TARGET_BUILD_LIBRARY_NAME="$3"
if [[ -z "$TARGET_BUILD_LIBRARY_NAME" ]]; then
    echo "Error: The library name can not be empty or null."
    exit 1
fi

TARGET_BUILD_OS=`get_target_build_os "$4"`
if [[ -z $TARGET_BUILD_OS ]]; then
    echo "Error: Unknown target build operating system: '$4'. Use 'host' to use the host build platform or use either: 'windows', 'macos', 'linux'."
    exit 1
fi

TARGET_BUILD_ARCH=`get_target_build_arch "$TARGET_BUILD_OS" "$5"`
if [[ -z $TARGET_BUILD_ARCH ]]; then
    echo "Error: Unknown target build architecture: '$5'. Use 'default' to use the host CPU architecture or use either: 'x86_64', 'arm64'."
    exit 1
fi

if [[ "$TARGET_BUILD_OS" == "linux" ]]; then
    TARGET_BUILD_LIBRARY_FILENAME="lib$TARGET_BUILD_LIBRARY_NAME.so"
elif [[ "$TARGET_BUILD_OS" == "macos" ]]; then
    TARGET_BUILD_LIBRARY_FILENAME="lib$TARGET_BUILD_LIBRARY_NAME.dylib"
elif [[ "$TARGET_BUILD_OS" == "windows" ]]; then
    TARGET_BUILD_LIBRARY_FILENAME="$TARGET_BUILD_LIBRARY_NAME.dll"
else
    echo "Unknown TARGET_BUILD_OS: '$TARGET_BUILD_OS'"
    exit 1
fi

TARGET_BUILD_CMAKE_ARGS="$6"

printf "'$0': Input validated.\n"
printf "\tTARGET_BUILD_INPUT_DIRECTORY_PATH=$TARGET_BUILD_INPUT_DIRECTORY_PATH\n"
printf "\tTARGET_BUILD_OUTPUT_DIRECTORY_PATH=$TARGET_BUILD_OUTPUT_DIRECTORY_PATH\n"
printf "\tTARGET_BUILD_OS=$TARGET_BUILD_OS\n"
printf "\tTARGET_BUILD_ARCH=$TARGET_BUILD_ARCH\n"
printf "\tTARGET_BUILD_LIBRARY_NAME=$TARGET_BUILD_LIBRARY_NAME\n"
printf "\tTARGET_BUILD_LIBRARY_FILENAME=$TARGET_BUILD_LIBRARY_FILENAME\n"
printf "\tTARGET_BUILD_CMAKE_ARGS=$TARGET_BUILD_CMAKE_ARGS\n"
printf "'$0': Running...\n"

build_library
if [[ $? -ne 0 ]]; then
    printf "'$0': Failed.\n"
    exit $?
else
    printf "'$0': Success.\n"
    exit 0
fi
