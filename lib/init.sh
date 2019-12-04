init-scripts-lib() {
    local lib_path="${1}"

    source "${lib_path}/require.sh"

    init-require-system "${lib_path}"
}

init-scripts-lib "${1}"
