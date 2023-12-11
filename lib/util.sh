path-to-script() {
    # Get the path of the outermost script calling this function.

    echo "$(readlink -f "${BASH_SOURCE[-1]}")"
}


script-name() {
    # Get the name of the outermost script calling this function.
    # Usually useful for usages.

    echo "$(basename "${BASH_SOURCE[-1]}")"
}


choose() {
    # Choose a value based on a flag (a ternary if operator).
    #
    # Usage: choose FLAG TRUE_VALUE FALSE_VALUE
    #
    # Positional arguments:
    #     FLAG          A 0/1 flag to select the value.
    #     TRUE_VALUE    The value to output if the flag is 1.
    #     FALSE_VALUE   The value to output if the flag is 0.

    local flag="${1}"
    local a="${2}"
    local b="${3}"

    if [[ ${flag} == '1' ]]
    then
        printf "%s" "${a}"
    else
        printf "%s" "${b}"
    fi
}


bool() {
    # Make a command return value into a boolean value.
    #
    # Usage: bool COMMAND [ARGUMENTS...]

    eval "$@" && printf 1 || printf 0
}

is-a-shortcut() {
    # Check if this script is being executed as a shortcut.
    # This is done by checking if the parent process is a known WM.
    #
    # Usage: is-a-shortcut

    local parent
    parent="$(ps -p"${PPID}" -o comm=)"

    case "$parent" in
        i3) true && return
    esac

    false
}
