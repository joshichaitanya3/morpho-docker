#!/bin/bash

# Check if any arguments were passed to the entrypoint script
if [ "$#" -gt 0 ]; then
    # If arguments were passed, execute the compiled binary with those arguments
    morpho6 "$@"
else
    # If no arguments were passed, start the REPL
    morpho6
fi