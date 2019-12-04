imported-var-name() {
    echo "${1//-/_}"_IMPORTED
}


init-require-system() {
    REQUIREPATH="${1}"
}


is-imported() {
    local imported_var="$(imported-var-name "${1}")"
    local is_imported="${!imported_var:-0}"

    [[ "${is_imported}" == "1" ]]
}


mark-imported() {
    local imported_var="$(imported-var-name "${1}")"

    eval "${imported_var}"=1
}


function script-path {
    local module="${1}"

    echo "${REQUIREPATH}/${1}".sh
}


function require {
    local module="${1}"

    is-imported "${module}" && return

    local module_path="$(script-path "${module}")"

    source "${module_path}" && mark-imported "${module}" && return

    echo "Could not require '${module}' successfully, with path' ${module_path}'." >&2
}
