require dependencies

depend xclip


set-clipboard() {
    # Set the X selection and clipboard clipboards to some text.
    #
    # Usage: choose FLAG TRUE_VALUE FALSE_VALUE
    #
    # Positional arguments:
    #     TEXT   A text to set the contents of the clipboards.

    local text="${1}"

    printf '%s' "${text}" | xclip
    printf '%s' "${text}" | xclip -sel c
}
