#!/bin/bash


# Usage: ./exec_all.sh -d <prod | dev> -c <command> [--shell]
#
# Options:
#   -d, --destination <prod | dev>  Specify the destination environment (prod or dev)
#   -c, --command <command>          Specify the command to execute
#   --shell                          Execute a custom system command instead of predefined commands
#   -h, --help                       Show this help message
#
# Available commands:
#   maintenance_on       turn on maintenance mode
#   maintenance_off      turn off maintenance mode
#   import_mode_on       turn on import mode
#   import_mode_off      turn off import mode
#


usage() {
    echo "Usage: $0 -d <prod | dev> -c <command> [--shell]"
    echo ""
    echo "Options:"
    echo "  -d, --destination <prod | dev>  Specify the destination environment (prod or dev)"
    echo "  -c, --command <command>          Specify the command to execute"
    echo "  --shell                          Execute a custom system command instead of predefined commands"
    echo "  -h, --help                       Show this help message"
    echo ""
    echo "Available commands:"
    echo "  maintenance_on       turn on maintenance mode"
    echo "  maintenance_off      turn off maintenance mode"
    echo "  import_mode_on       turn on import mode"
    echo "  import_mode_off      turn off import mode"
    echo ""
}
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--destination)
            DESTINATION="$2"
            shift 2
            ;;
        -c|--command)
            COMMAND="$2"
            shift 2
            ;;
        --shell)
            SHELL=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done
if [[ -z "$DESTINATION" || -z "$COMMAND" ]]; then
    echo "Error: Destination and command are required."
    usage
    exit 1
fi
if [[ "$DESTINATION" != "prod" && "$DESTINATION" != "dev" ]]; then
    echo "Error: Destination must be 'prod' or 'dev'."
    usage
    exit 1
fi

# If the command is not in the list and shell is false, show an error
if [[ "$COMMAND" != "maintenance_on" && "$COMMAND" != "maintenance_off" && \
      "$COMMAND" != "import_mode_on" && "$COMMAND" != "import_mode_off" && \
      "$SHELL" == false ]]; then
    echo "Error: Unknown command '$COMMAND'."
    usage
    exit 1
fi
# Execute the command on all instances
for INSTANCE in $(ls -1 config/ | grep "deploy.${DESTINATION}" | sed 's/deploy\.//; s/\.yml//'); do
    echo "Executing '$COMMAND' on instance '$INSTANCE'..."
    if [[ "$SHELL" == true ]]; then
        kamal app exec -p -r web --reuse "$COMMAND" -d $INSTANCE
    elif [[ "$COMMAND" == "maintenance_on" ]]; then
        kamal app exec -p -r web --reuse "/docker-entrypoint.sh bin/rails r 'Setting.set(\"maintenance_mode\", true)'" -d $INSTANCE
    elif [[ "$COMMAND" == "maintenance_off" ]]; then
        kamal app exec -p -r web --reuse "/docker-entrypoint.sh bin/rails r 'Setting.set(\"maintenance_mode\", false)'" -d $INSTANCE
    elif [[ "$COMMAND" == "import_mode_on" ]]; then
        kamal app exec -p -r web --reuse "/docker-entrypoint.sh bin/rails r 'Setting.set(\"import_mode\", true)'" -d $INSTANCE
    elif [[ "$COMMAND" == "import_mode_off" ]]; then
        kamal app exec -p -r web --reuse "/docker-entrypoint.sh bin/rails r 'Setting.set(\"import_mode\", false)'" -d $INSTANCE
    else
        echo "Error: Unknown command '$COMMAND'."
        exit 1
    fi
    if [[ $? -ne 0 ]]; then
        echo "Error: Command failed on instance '$INSTANCE'."
        exit 1
    fi
done