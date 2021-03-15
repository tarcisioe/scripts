require path-util
require ui


check-dependencies() {
    # Check if a list of dependency commands are available.
    #
    # Usage: check-dependencies [COMMANDS...]
    #
    # Positional arguments:
    #     COMMANDS   Commands to check for availability.

    local failed=0

    for command in "${@}"
    do
        command-available "${command}" || {
            print-bad "Command $(yellow "${command}") unavailable." \
                "Please install it to use this script."
            failed=1
        }
    done

    if [[ ${failed} == '1' ]]
    then
        die "Some dependencies are not met. Exiting."
    fi
}
