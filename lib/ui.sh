require util


escape() {
    # Add a terminal escape code before a printed string and a format reset to
    # the end.

    printf '\e['"${1}"'m%s\e[0m' "$2"
}

bold() {
    escape 1 "${1}"
}

red() {
    escape 31 "${1}"
}

green() {
    escape 32 "${1}"
}

yellow() {
    escape 33 "${1}"
}

bad() {
    # Make a bad (red command name) message.

    echo -ne "$(bold $(red "$(script-name)"))": "$@"
}

good() {
    # Make a good (green command name) message.

    echo -ne "$(bold $(green "$(script-name)"))": "$@"
}

info() {
    # Make an info (yellow command name) message.

    echo -ne "$(bold $(yellow "$(script-name)"))": "$@"
}

log() {
    # Print a message to the log output (stderr).

    echo "$@" 1>&2
}

print-bad() {
    # Print a bad (red command name) message to the log output (stderr).
    #
    # Always returns non-zero, to ensure failure with `set -e`.

    log "$(bad "$@")" 1>&2 && return 1
}

print-good() {
    # Print a good (green command name) message to the log output (stderr).

    log "$(good "$@")" 1>&2
}

print-info() {
    # Print an info (yellow command name) message to the log output (stderr).

    log "$(info "$@")" 1>&2
}

die() {
    # Prints an error message and exits `bash` right away.

    print-bad "$@"
    exit 1
}

die-usage() {
    # Die showing the program usage. Requires a usage function.

    usage && die "$@"
}
