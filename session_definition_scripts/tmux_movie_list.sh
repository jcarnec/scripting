#!/bin/bash


code ~/non-work/movie-list/

# Define the session name
SESSION="ml_session"

# Create a new detached tmux session named 'ml_session' with the first window named 'main'
tmux new-session -d -s "$SESSION" -n main

# Split the first window vertically (-v) within the 'ml_session' session
tmux split-window -v -t "$SESSION":main

# Send the "ml_start_fronted" command to the first pane (pane 0) of the 'main' window
tmux send-keys -t "$SESSION":main.0 "ml_start_fronted" C-m

# Send the "ml_start_backend" command to the second pane (pane 1) of the 'main' window
tmux send-keys -t "$SESSION":main.1 "ml_start_backend" C-m

# Optionally, select the first pane to ensure it's active when attaching
tmux select-pane -t "$SESSION":main.0

# Launch a new gnome-terminal that attaches to the 'ml_session' tmux session
gnome-terminal --title="ml_session" -- bash -c "tmux attach-session -t $SESSION; exec bash"

