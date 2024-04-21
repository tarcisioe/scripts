require compat
require dependencies


function _use-xclip() {
    depend xclip

    function get-clipboard() {
        xclip -o
    }

    function set-clipboard-from-stdin() {
        # Set the clipboard with contents from stdin on X with xclip.
        #
        # Usage: set-clipboard-from-stdin [PRIMARY] [MIME_TYPE]
        #
        # Positional arguments:
        #     PRIMARY     A 0/1 flag on whether to set the 'primary' or the
        #                 'clipboard' clipboard.
        #     MIME_TYPE   The mime type of whatever is being sent to the
        #                 clipboard.

        local primary="${1:-0}"
        local mime_type="${2:-}"
        local flags

        [[ "${primary}" == 1 ]] &&
            flags=( -sel primary ) ||
            flags=( -sel clipboard )

        [[ -n "${mime_type}" ]] &&
            flags+=( -t "${mime_type}" )

        xclip "${flags[@]}"
    }
}

function _use-wl-copy() {
    depend wl-copy wl-paste

    function get-clipboard() {
        wl-paste
    }

    function set-clipboard-from-stdin() {
        # Set the clipboard with contents from stdin on Wayland with wl-copy.
        #
        # Usage: set-clipboard-from-stdin [PRIMARY] [MIME_TYPE]
        #
        # Positional arguments:
        #     PRIMARY     A 0/1 flag on whether to set the 'primary' or the
        #                 'clipboard' clipboard.
        #     MIME_TYPE   The mime type of whatever is being sent to the
        #                 clipboard.

        local primary="${1:-0}"
        local mime_type="${2:-}"
        local flags

        [[ "${primary}" == 1 ]] &&
            flags=( --primary ) ||
            flags=(  )

        [[ -n "${mime_type}" ]] &&
            flags+=( -t "${mime_type}" )

        wl-copy "${flags[@]}"
    }
}

x11-or-wayland \
    _use-xclip \
    _use-wl-copy

set-clipboard() {
    # Set the 'clipboard' and 'primary' clipboards to some text.
    #
    # Usage: set-clipboard TEXT
    #
    # Positional arguments:
    #     TEXT   A text to set the contents of the clipboards.

    local text="${1}"

    printf '%s' "${text}" | set-clipboard-from-stdin 1
    printf '%s' "${text}" | set-clipboard-from-stdin
}
