#!/bin/bash

# Get the list of logged-in users via SSH
users=$(who | grep 'pts/' | awk '{print $1}')

# Loop through each user and get their connection information
for user in $users; do
    # Get the number of active connections for the user
    num_connections=$(who | grep $user | wc -l)

    # Check if the user is still connected
    if [ $num_connections -eq 0 ]; then
        status="Offline"
    else
        status="Online"
    fi

    # Get the duration of the user's connection
    duration=$(who | grep $user | awk '{print $4}')

    # Print the user's information
    echo "$user - $status - $num_connections connections - $duration"
done
