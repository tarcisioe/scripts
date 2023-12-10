require util


get-wrapped-command() {
    local script_name="$(script-name)"

    local script="$(path-to-script)"

    local possibilities="$(which -a ${script_name})"

    for option in $possibilities
    do
        if [[ "$(readlink -f "$option")" != "$script" ]]
        then
            echo "$option"
            break
        fi
    done

    return 1
}

wrap() {
    # Wrap a command with the same name as the calling script, which comes after
    # it in `which -a`.
    #
    # This execs a process on success, or fails with no output.
    #
    # Usage: wrap [COMMAND_ARGS...]
    #
    # Positional arguments:
    #     COMMAND_ARGS   Arguments to be passed to the first command with the
    #                    same name as the calling script that `which` finds.

    local command="$(get-wrapped-command)" || return 1
    exec "${command}" "$@"
}


wrap-no-exec() {
    # Wrap a command with the same name as the calling script, which comes after
    # it in `which -a`.
    #
    # This runs a process (without using exec) on success, or fails with no output.
    #
    # Usage: wrap [COMMAND_ARGS...]
    #
    # Positional arguments:
    #     COMMAND_ARGS   Arguments to be passed to the first command with the
    #                    same name as the calling script that `which` finds.

    local command="$(get-wrapped-command)" || return 1
    "${command}" "$@"
}
