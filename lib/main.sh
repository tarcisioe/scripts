require dependencies
require util


SCRIPTLIB_DEFAULT_ARG_USAGE="\
Optional arguments:
    -h/--help    Print this help message and exit."


echo-if-nonempty() {
    local text="${1}"

    if [[ -n "${text}" ]]
    then
        echo "${text}"
    fi
}


usage() {
    echo "Usage: $(script-name) [OPTIONS...] ${SCRIPTLIB_ARGS:-}" &&
    echo-if-nonempty "${SCRIPTLIB_DESCRIPTION:-}" &&
    echo &&
    echo "${SCRIPTLIB_DEFAULT_ARG_USAGE}" &&
    echo-if-nonempty "${SCRIPTLIB_OPT_ARGS:-}" &&

    if [[ -n "${SCRIPTLIB_POS_ARGS:-}" ]]
    then
        echo
        echo "Positional arguments:"
        echo "${SCRIPTLIB_POS_ARGS}"
    fi
}


main-with-opts() {
    set -e

    check-dependencies

    local short="${1}"
    local long="${2}"
    local f="${3}"

    local options
    options=$(getopt -o h"${short}" -l help,"${long}" -- "${@:4}")
    eval set -- "$options"

    while true; do
        case "${1:-}" in
            -h|--help)
                usage && exit 0
                ;;
            --) shift ;&
            *) break ;;
        esac
        shift
    done

    "$f" "$@"
}

main() {
    main-with-opts "" "" "$@"
}
