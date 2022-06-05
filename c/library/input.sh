#!/bin/bash
# NOTE: Input validation for the script; see `main.sh`.

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
. $DIR/../../utility.sh

function get_input_directory_path {
    local PATH=`get_full_path $1`

    if [[ ! -d "$PATH" ]]; then
        echo ""
        return 1
    fi

    if [[ ! -f "$PATH/CMakeLists.txt" ]]; then
        echo ""
        return 1
    fi

    echo "$PATH"
    return 0
}

function get_output_directory_path {
    mkdir -p $1
    if [[ $? -ne 0 ]]; then
        echo ""
        return 1
    fi

    local PATH=`get_full_path $1`
    echo "$PATH"
    return 0
}

function get_target_build_os {
    if [[ -z "$1" || $1 == "host" ]]; then
        local OS="$(get_operating_system)"
    else
        local OS=""
    fi

    if [[
        "$OS" != "windows" &&
        "$OS" != "macos" &&
        "$OS" != "linux"
    ]]; then
        echo ""
        return 1
    fi

    echo "$OS"
    return 0
}

function get_target_build_arch {
    if [[ -z "$2" || $2 == "default" ]]; then
        if [[ "$1" == "macos" ]]; then
            echo "x86_64;arm64"
            return 0
        else
            echo "$(uname -m)"
            return 0
        fi
    else
        if [[ "$2" != "x86_64" && "$2" != "arm64" ]]; then
            echo ""
            return 1
        else
            echo "$2"
            return 0
        fi
    fi
}