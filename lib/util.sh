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
    eval "$@" && printf 1 || printf 0
}
