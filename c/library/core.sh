#!/bin/bash
# NOTE: The core functions for the script; see `main.sh`.

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
. $DIR/../../utility.sh

function build_library() {
    local BUILD_DIRECTORY_PATH="$TARGET_BUILD_OUTPUT_DIRECTORY_PATH/cmake-build-release"
    rm -rf BUILD_DIRECTORY_PATH

    if [[ "$TARGET_BUILD_OS" == "macos" ]]; then
        local CMAKE_ARCH_ARGS="-DCMAKE_OSX_ARCHITECTURES=$TARGET_BUILD_ARCH"
    fi

    cmake -S $TARGET_BUILD_INPUT_DIRECTORY_PATH -B $BUILD_DIRECTORY_PATH $CMAKE_ARCH_ARGS \
        `# change output directories` \
        -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY=$BUILD_DIRECTORY_PATH -DCMAKE_LIBRARY_OUTPUT_DIRECTORY=$BUILD_DIRECTORY_PATH -DCMAKE_RUNTIME_OUTPUT_DIRECTORY=$BUILD_DIRECTORY_PATH -DCMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE=$BUILD_DIRECTORY_PATH \
        `# project specific` \
        "$TARGET_BUILD_CMAKE_ARGS"
    if [[ $? -ne 0 ]]; then return $?; fi

    cmake --build $BUILD_DIRECTORY_PATH --config Release
    if [[ $? -ne 0 ]]; then return $?; fi

    LIBRARY_FILE_PATH_BUILD="$BUILD_DIRECTORY_PATH/$TARGET_BUILD_LIBRARY_FILENAME"
    if [[ -z "$LIBRARY_FILE_PATH_BUILD" ]]; then
        echo "The built file '$LIBRARY_FILE_PATH_BUILD' does not exist!"
        return 1
    fi

    LIBRARY_FILE_PATH="$TARGET_BUILD_OUTPUT_DIRECTORY_PATH/$TARGET_BUILD_LIBRARY_FILENAME"
    mv "$LIBRARY_FILE_PATH_BUILD" "$LIBRARY_FILE_PATH"
    if [[ $? -ne 0 ]]; then return $?; fi
    echo "Copied '$LIBRARY_FILE_PATH_BUILD' to '$LIBRARY_FILE_PATH'"

    rm -r $BUILD_DIRECTORY_PATH
    if [[ $? -ne 0 ]]; then return $?; fi
}