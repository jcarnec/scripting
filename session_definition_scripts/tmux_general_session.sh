#!/bin/bash

tmux new-session -d -s "general_session" -n main
gnome-terminal --title="general_session" -- bash -c "tmux attach-session -t general_session; exec bash"

