#!/bin/bash

# Read all UUIDs from usernamecache.json
uuids=$(jq -r 'keys_unsorted[]' /home/ubuntu/server/usernamecache.json)

# Variable to store the multiline message
multiline_message="Total World Time"$'\n'

# Loop over each UUID
for uuid in $uuids; do
    # Get the username for a uuid
    username=$(jq -r ".\"$uuid\"" /home/ubuntu/server/usernamecache.json)

    # Construct the path to the corresponding JSON file in /home/ubuntu/server/world/stats/
    json_file="/home/ubuntu/server/world/stats/${uuid}.json"

    # Check if the JSON file exists
    if [ -e "$json_file" ]; then
        # Extract total world time from the JSON file
        total_world_time=$(jq -r '.stats."minecraft:custom"."minecraft:total_world_time"' "$json_file")

        # Convert total world time to hours
        total_hours=$(awk "BEGIN {print $total_world_time / 72000}")

        # Append to the multiline message
        multiline_message+="Username: $username : $total_hours hours"$'\n'
    else
        multiline_message+="Error: JSON file not found for $uuid"$'\n'
    fi
done

echo "$multiline_message"
