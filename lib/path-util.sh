command-available() {
    # Silent which to check if a command is available.
    #
    # Usage: command-available [COMMAND]
    #
    # Positional arguments:
    #     COMMAND   Which command to check for existence.

    local command="${1}"

    which "${command}" > /dev/null 2>&1
}


call-if-available()
{
    # Call a command if it exists, else fail with no output.
    #
    # Usage: call-if-available [COMMAND] [COMMAND_ARGS...]
    #
    # Positional arguments:
    #     COMMAND        The command to call.
    #     COMMAND_ARGS   Arguments to forward to the command.

    local command="${1}"

    command-available "${command}" && "$@"
}


exec-if-available()
{
    # Exec a command if it exists, else fail with no output.
    #
    # Usage: exec-if-available [COMMAND] [COMMAND_ARGS...]
    #
    # Positional arguments:
    #     COMMAND        The command to exec.
    #     COMMAND_ARGS   Arguments to forward to the command.

    local command="${1}"

    command-available "${command}" && exec "$@"
}


function first-command-of {
    for candidate in "$@"
    do
        if command-available "${candidate}"
        then
            echo "${candidate}"
            return
        fi
    done

    return 1
}


function first-file-of {
    for candidate in "$@"
    do
        if [[ -f "${candidate}" ]]
        then
            echo "${candidate}"
            return
        fi
    done

    return 1
}
