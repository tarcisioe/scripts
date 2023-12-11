require path-util
require ui


SCRIPTLIB_DEPS=()


depend() {
    # Register dependency commands to check later.
    #
    # Usage: depend [COMMANDS...]
    #
    # Positional arguments:
    #     COMMANDS   Commands to check later for availability.

    SCRIPTLIB_DEPS+=("$@")
}


check-dependencies() {
    # Check if the registered dependencies are available.
    #
    # Usage: check-dependencies

    local failed=()

    for command in "${SCRIPTLIB_DEPS[@]}"
    do
        command-available "${command}" ||
            failed+=("${command}")
    done

    if (( ${#failed[@]} ))
    then
        print-bad "Commands unavailable: $(yellow "${failed[*]}")." \
                "Please install it to use this script."
        die "Some dependencies are not met. Exiting."
    fi
}
