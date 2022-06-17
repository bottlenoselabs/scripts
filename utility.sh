#!/bin/bash
# NOTE: Various common utility functions.

function exit_if_last_command_failed() {
    local error=$?
    if [ $error -ne 0 ]; then
        echo "Last command failed: $error"
        return $error
    fi
    return 0
}

function get_operating_system() {
    local UNAME_STRING="$(uname -a)"
    case "${UNAME_STRING}" in
        *Microsoft*)    local TARGET_OS="windows";;
        *microsoft*)    local TARGET_OS="windows";;
        Linux*)         local TARGET_OS="linux";;
        Darwin*)        local TARGET_OS="macos";;
        CYGWIN*)        local TARGET_OS="linux";;
        MINGW*)         local TARGET_OS="windows";;
        *Msys)          local TARGET_OS="windows";;
        *)              local TARGET_OS="UNKNOWN:${UNAME_STRING}"
    esac
    echo "$TARGET_OS"
    return 0
}

# NOTE: Gets the full path of a file or directory on disk.
# INPUT:
#   $1: The path.
#   OUTPUT: The full path.
function get_full_path() {
    if [[ ! -d "$1" && ! -f "$1" ]]; then
        echo ""
        return 1
    fi

    local TARGET_OS="$(get_operating_system)"
    if [[ "$TARGET_OS" == "linux" ]]; then
        echo "$(readlink -f $1)"
        return 0
    elif [[ "$TARGET_OS" == "macos" ]]; then
        echo "$(perl -MCwd -e 'print Cwd::abs_path shift' $1)"
        return 0
    elif [[ "$TARGET_OS" == "windows" ]]; then
        echo "$1"
        return 0
    else
        echo ""
        return 1
    fi
}