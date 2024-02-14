#!/bin/bash

# for each argument passed in, call a script with the argument passed
for arg in "$@"
do
    echo -e "\n---\n\nRunning test $arg\n\n---\n" >> results.txt

    echo "Running test $arg"
    ./notify-send.sh "Running test $arg"
    ./reset_ycsb.sh "$arg"

    echo -e "\n-\n\nFinished with test $arg\n\n-\n" >> results.txt
    ./notify-send.sh "Finished test $arg"
    #ntfy "finished test $arg"
done

echo "Finished running every single test"
#ntfy "finished test $arg"

