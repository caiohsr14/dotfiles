#!/bin/bash

# Find the sink input for Music Player Daemon
sink_input_raw=$(pactl list sink-inputs | awk '
    /Sink Input/ { current_sink_input = $3 }
    /application.name = "Music Player Daemon"/ { print current_sink_input; exit }
')
sink_input=${sink_input_raw#\#} # Remove the # prefix

# If no mpd sink input is found, exit
if [ -z "$sink_input" ]; then
    exit 0
fi

# Get the current sink for mpd
current_sink=$(pactl list sink-inputs | awk -v si="#$sink_input" '
    $0 ~ "Sink Input " si { in_block = 1 }
    in_block && /Sink:/ { print $2; exit }
')

# Get the list of all available sinks
sinks=($(pamixer --list-sinks | awk '/^Sinks:/ { next } { print $1 }'))

# Find the index of the current sink
current_index=-1
for i in "${!sinks[@]}"; do
    if [[ "${sinks[$i]}" == "$current_sink" ]]; then
        current_index=$i
        break
    fi
done

if [ "$current_index" -eq -1 ]; then
    exit 1
fi

# Calculate the index of the next sink
next_index=$(( (current_index + 1) % ${#sinks[@]} ))
next_sink=${sinks[$next_index]}

# Move the mpd sink input to the next sink
pactl move-sink-input "$sink_input" "$next_sink"