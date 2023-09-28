#!/bin/bash

# for each argument passed in, call a script with the argument passed
for arg in "$@"
do
    echo -e "\n---\n\nRunning test $arg\n\n---\n" >> results.txt

    echo "Running test $arg"
    notify-send "Running test $arg"

    ./reset_ycsb.sh "$arg"
    notify-send "Finished test $arg"
    #ntfy "finished test $arg"
done

