require dependencies

check-dependencies notify-send


send-notification() {
    # Send text on the body of a notification.
    #
    # Usage: send-notification TEXT [DURATION]
    #
    # Positional arguments:
    #     TEXT       Text to show in the notification.
    #     DURATION   (Optional) How much time to show the notification for.
    #                In ms. If omitted, defaults to 1000.

    local text="${1}"
    local duration="${2:-1000}"

    notify-send -t "${duration}" -- ' ' "${text}"
}
