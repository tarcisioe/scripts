command-available() {
    # Silent which to check if a command is available.
    local command="${1}"

    which "${command}" > /dev/null 2>&1
}
