#!/bin/bash
# NOTE: The core functions for the script; see `main.sh`.

DIRECTORY_SCRIPTS_C_LIBRARY_CORE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
. $DIRECTORY_SCRIPTS_C_LIBRARY_CORE/utility.sh

function build_library() {
    local BUILD_DIRECTORY_PATH="$TARGET_BUILD_OUTPUT_DIRECTORY_PATH/cmake-build-release-$TARGET_BUILD_LIBRARY_NAME"
    rm -rf $BUILD_DIRECTORY_PATH

    if [[ "$TARGET_BUILD_OS" == "macos" ]]; then
        local CMAKE_ARCH_ARGS="-DCMAKE_OSX_ARCHITECTURES=$TARGET_BUILD_ARCH"
    fi

    PREVIOUS_DIRECTORY=`pwd`
    cd $TARGET_BUILD_INPUT_DIRECTORY_PATH
    cmake -S "./" -B $BUILD_DIRECTORY_PATH $CMAKE_ARCH_ARGS \
        `# change output directories` \
        -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY=$BUILD_DIRECTORY_PATH -DCMAKE_LIBRARY_OUTPUT_DIRECTORY=$BUILD_DIRECTORY_PATH -DCMAKE_RUNTIME_OUTPUT_DIRECTORY=$BUILD_DIRECTORY_PATH -DCMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE=$BUILD_DIRECTORY_PATH -DCMAKE_LIBRARY_OUTPUT_DIRECTORY_RELEASE=$BUILD_DIRECTORY_PATH \
        `# project specific` \
        $TARGET_BUILD_CMAKE_ARGS
    if [[ $? -ne 0 ]]; then return $?; fi
    cd $PREVIOUS_DIRECTORY

    cmake --build $BUILD_DIRECTORY_PATH --config Release
    if [[ $? -ne 0 ]]; then return $?; fi

    LIBRARY_FILE_PATH_BUILD=`get_full_path $BUILD_DIRECTORY_PATH/$TARGET_BUILD_LIBRARY_FILENAME_SEARCH`

    if [[ "$TARGET_BUILD_OS" == "windows" ]]; then
        LIBRARY_FILE_PATH_BUILD_LIB=`get_full_path $BUILD_DIRECTORY_PATH/$TARGET_BUILD_LIBRARY_FILENAME_LIB_SEARCH`
    fi

    if [[ -z "$LIBRARY_FILE_PATH_BUILD" ]]; then
        echo "The built native shared library file '$LIBRARY_FILE_PATH_BUILD' does not exist!"
        return 1
    fi
    if [[ "$TARGET_BUILD_OS" == "windows" ]]; then
        if [[ -z "$LIBRARY_FILE_PATH_BUILD_LIB" ]]; then
            echo "The built native static library file '$LIBRARY_FILE_PATH_BUILD' does not exist!"
            return 1
        fi
    fi

    LIBRARY_FILE_PATH="$TARGET_BUILD_OUTPUT_BINARY_DIRECTORY_PATH/$TARGET_BUILD_LIBRARY_FILENAME"
    mv "$LIBRARY_FILE_PATH_BUILD" "$LIBRARY_FILE_PATH"
    if [[ $? -ne 0 ]]; then return $?; fi
    echo "Copied '$LIBRARY_FILE_PATH_BUILD' to '$LIBRARY_FILE_PATH'"

    if [[ "$TARGET_BUILD_OS" == "windows" ]]; then
        LIBRARY_FILE_PATH_LIB="$TARGET_BUILD_OUTPUT_BINARY_DIRECTORY_PATH/$TARGET_BUILD_LIBRARY_FILENAME_LIB"
        echo ""
        mv "$LIBRARY_FILE_PATH_BUILD_LIB" "$LIBRARY_FILE_PATH_LIB"
        if [[ $? -ne 0 ]]; then return $?; fi
        echo "Copied '$LIBRARY_FILE_PATH_BUILD_LIB' to '$LIBRARY_FILE_PATH_LIB'"
    fi

    if [[ $? -ne 0 ]]; then return $?; fi
}