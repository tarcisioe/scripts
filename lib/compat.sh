function x11-or-wayland() {
    local x11_command="${1}"
    local wayland_command="${2}"

    case "${XDG_SESSION_TYPE}" in
        "x11") "${x11_command}" ;;
        "wayland") "${wayland_command}" ;;
    esac
}
