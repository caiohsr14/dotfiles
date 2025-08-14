#!/bin/bash

# Get a list of all active sink inputs (audio streams)
sink_inputs=($(pactl list short sink-inputs | awk '{print $1}'))

# Get a list of all available sinks (output devices)
sinks=($(pamixer --list-sinks | awk '/^Sinks:/ { next } { print $1 }'))

# If there are no sinks or no sink inputs, exit
if [ ${#sinks[@]} -eq 0 ] || [ ${#sink_inputs[@]} -eq 0 ]; then
    exit 0
fi

# Loop through each active sink input
for input_id in "${sink_inputs[@]}"; do
    # Get the current sink for this input
    current_sink=$(pactl list sink-inputs | awk -v input_id="$input_id" '
        $0 ~ "Sink Input #" input_id { in_input = 1 }
        in_input && /Sink:/ { print $2; exit }
    ')

    # Find the index of the current sink in the list of all sinks
    current_index=-1
    for i in "${!sinks[@]}"; do
        if [[ "${sinks[$i]}" == "$current_sink" ]]; then
            current_index=$i
            break
        fi
    done

    # If the current sink is not found (shouldn't happen, but for safety)
    if [ "$current_index" -eq -1 ]; then
        continue
    fi

    # Calculate the index of the next sink
    next_index=$(( (current_index + 1) % ${#sinks[@]} ))
    next_sink=${sinks[$next_index]}

    # Move the sink input to the next sink
    pactl move-sink-input "$input_id" "$next_sink"
done