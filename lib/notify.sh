require dependencies

depend notify-send


send-notification() {
    # Send text on the body of a notification.
    #
    # Usage: send-notification TEXT [DURATION]
    #
    # Positional arguments:
    #     TEXT       Text to show in the notification.
    #     URGENCY    Urgency of the notification (low, normal, critical).
    #     DURATION   (Optional) How much time to show the notification for.
    #                In ms. If omitted, defaults to 1000.

    local text="${1}"
    local urgency="${2:-normal}"
    local duration="${3:-1000}"

    notify-send -u "${urgency}" -t "${duration}" -- ' ' "${text}"
}


stdin-to-notification() (
    # Forward the received stdin to a notification.
    #
    # Usage: send-notification [URGENCY] [DURATION]
    #
    # Positional arguments:
    #     URGENCY    Urgency of the notification (low, normal, critical).
    #     DURATION   (Optional) How much time to show the notification for.
    #                In ms. If omitted, defaults to 1000.

    local urgency="${1:-normal}"
    local duration="${2:-1000}"

    local input

    input="$(</dev/stdin)"

    send-notification "${input}" "${urgency}" "${duration}"
)


stderr-to-notifications() {
    # Execute a command and forward its stderr as a critical notification.
    #
    # Usage: stderr-to-notification COMMAND [ARGUMENTS...]

    "$@" 2> >(stdin-to-notification critical)
}


output-to-notifications() {
    # Execute a command and forward its stdout as a notification and its
    # stderr as a critical notification.
    #
    # Usage: stderr-to-notification COMMAND [ARGUMENTS...]

    stderr-to-notifications "$@" > >(stdin-to-notification)
}


wrap-shortcut-stderr() {
    # Execute a command and forward its stderr to a notification if running
    # as a shortcut.
    #
    # Usage: stderr-to-notification COMMAND [ARGUMENTS...]

    if ! is-a-shortcut
    then
        "$@"
        return
    fi

    stderr-to-notifications "$@"
}


wrap-shortcut() {
    # Execute a command and forward its outputs to notifications if running
    # as a shortcut.
    #
    # Usage: stderr-to-notification COMMAND [ARGUMENTS...]

    if ! is-a-shortcut
    then
        "$@"
        return
    fi

    output-to-notifications "$@"
}
