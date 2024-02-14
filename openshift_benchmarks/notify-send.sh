#!/bin/bash

# Check if notify-send exists in the system's PATH
if command -v notify-send &>/dev/null; then
    # If notify-send is found, run it with all supplied arguments
    notify-send "$@"
else
    # If notify-send is not found, echo the arguments
    echo "$@"
fi

