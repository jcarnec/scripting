#!/bin/bash

session="ml_session"

# Start a new tmux session
tmux new-session -d -s $session

# Split left pane into two horizontal panes
tmux split-window -v

# Run frontend command in the second pane
tmux send-keys -t 0 "ml_start_fronted" C-m

# Run backend command in the first pane with sudo
tmux send-keys -t 1 "ml_start_backend" C-m

# Attach to the session
tmux attach-session -t $session

