require catch-outputs
require dependencies


user-login-shell() {
    getent passwd "${LOGNAME}" | cut -d: -f7
}


send-notification() {
    # Send text on the body of a notification.
    #
    # Usage: send-notification TEXT [DURATION]
    #
    # Positional arguments:
    #     TEXT       Text to show in the notification.
    #     DURATION   (Optional) How much time to show the notification for.
    #                In ms. If omitted, defaults to 1000.
    #
    check-dependencies notify-send

    local text="${1}"
    local urgency="${2:-normal}"
    local duration="${3:-1000}"

    notify-send -u "${urgency}" -t "${duration}" -- ' ' "${text}"
}


is-a-shortcut() {
    # Check if this script is being executed as a shortcut.
    # This is done by checking if the parent process is a known WM.
    #
    # Usage: is parent a shell

    local parent
    parent="$(ps -p"${PPID}" -o comm=)"

    case "$parent" in
        i3) true && return
    esac

    false
}


capture-retval() {
    # Check if the parent process is the user's login shell or a known shell.
    #
    # Usage: capture-retval VARIABLE COMMAND [ARGUMENTS...]
    #
    # Positional arguments:
    #     VARIABLE    The variable name to put the return value in.
    #     COMMAND     The command to run.
    #     ARGUMENTS   The arguments for the command that should be executed.

    local -n out="${1}"

    "${@:2}" &&
        out=0 ||
        out="${?}"
}


stdin-to-notification() (
    local urgency="${1:-normal}"
    local duration="${2:-1000}"

    local input

    input="$(</dev/stdin)"

    send-notification "${input}" "${urgency}" "${duration}"
)


stderr-to-notifications() {
    local ret

    capture-retval ret "$@" 2> >(stdin-to-notification critical)

    return "${ret}"
}


output-to-notifications() {
    local ret

    capture-retval ret stderr-to-notifications "$@" > >(stdin-to-notification)

    return "${ret}"
}


wrap-shortcut-stderr() {
    if ! is-a-shortcut
    then
        "$@"
        return
    fi

    stderr-to-notifications "$@"
}


wrap-shortcut() {
    if ! is-a-shortcut
    then
        "$@"
        return
    fi

    output-to-notifications "$@"
}
