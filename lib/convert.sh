require dependencies

depend ffmpeg


function log-with-date() {
    log "[$(date +%H:%M:%S)]" "${@}"
}


function run-ffmpeg() {
    # ffmpeg treats termination with Ctrl+C as a normal exit and returns 0
    # this detects Ctrl+C, terminates ffmpeg and fixes the return value
    #
    # Usage: run-ffmpeg ARGS...
    #
    # Positional arguments:
    #     ARGS: Arguments to pass to ffmpeg.

    local ffmpeg_pid
    local ffmpeg_killed=false

    function handle-termination() {
        [[ -z "${ffmpeg_pid}" ]] && return

        kill "${ffmpeg_pid}"

        ffmpeg_killed=true
    }

    trap handle-termination INT

    ffmpeg "${@}" < /dev/null &

    ffmpeg_pid="${!}"
    wait "${ffmpeg_pid}" || return 1

    $ffmpeg_killed && return 1

    trap - INT
    unfunction handle-termination

    return 0
}


function _change-extension() {
    local original="${1}"
    local new_extension="${2}"

    echo "${original%.*}.${new_extension}"
}


function _check-complete-file() {
    local path="${1}"

    # Inexistent file is incomplete
    [[ -f "${path}" ]] || return 1

    # Incomplete marker exists
    [[ -f "${path}".incomplete ]] && {
        log-with-date "File ${path} was still marked as incomplete."
        return 1
    }

    return 0
}


function _make-incomplete-marker() {
    local path="${1}"

    touch "${path}.incomplete"
}


function _clear-incomplete-marker() {
    local path="${1}"

    rm "${path}.incomplete"
}


function _reencode-if-incomplete() {
    # Convert a single file if the destination doesn't exist.
    #
    # Usage: _reencode-if-incomplete INPUT OUTPUT LOGFILE FFMPEG_ARGS...
    #
    # Positional arguments:
    #     INPUT         Path for the input file.
    #     OUTPUT        Path for the converted file.
    #     LOGFILE       Where to output logs.
    #     FFMPEG_ARGS   Arguments to pass to ffmpeg, except for input and
    #                   output

    local input="${1}"
    local output="${2}"
    local logfile="${3}"
    shift 3

    _check-complete-file "${output}" && {
        log-with-date "File ${output} is complete, skipping."
        return 0
    }

    mkdir -p "$(dirname "${output}")"

    rm -f "${output}"
    _make-incomplete-marker "${output}"

    log-with-date "Starting to reencode ${input}."

    run-ffmpeg -i "${input}" "${@}" "${output}" 2> "${logfile}" &&
        {
            _clear-incomplete-marker "${output}" &&
                log-with-date "Finished reencoding ${output}, clearing " \
                    "incomplete marker."
        } ||
        return 1
}


function convert-files() {
    # Convert a list of files from stdin using ffmpeg. Filenames should be
    # relative to SRCDIR. The same directory structure will be replicated on
    # DESTDIR. All files will have extension EXTENSION and the flags used are
    # the remaining arguments passed to the function.
    #
    # Usage: _convert-files SRCDIR DESTDIR EXTENSION FFMPEG_ARGS...
    #
    # Positional arguments:
    #     SRCDIR        The directory where the original files reside.
    #     DESTDIR       The directory where the converted files should be
    #                   placed.
    #     EXTENSION     The extension for the converted files.
    #     LOGFILE       Where to output logs.
    #     FFMPEG_ARGS   Arguments to pass to ffmpeg, except for input and
    #                   output.

    local srcdir="${1}"
    local desttdir="${2}"
    local extension="${3}"
    local logfile="${4}"
    shift 4

    local line
    while read -r line
    do
        local input="${srcdir}/${line}"
        local output
        output="$(_change-extension "${destdir}/${line}" "${extension}")"

        _reencode-if-incomplete "${input}" "${output}" "${logfile}" \
        "${@}" ||
            return 1
    done
}
