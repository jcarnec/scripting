#!/bin/bash
tf_code() {
    cd ~/non-work/top-down-fighter--
    code .
}

one_monitor_hdmi() {
    xrandr --output HDMI-1 --auto --primary --output eDP-1 --off
}

gpt-search-command() {
    # kill session if it exists
    tmux kill-session -t gpt-search
    tmux new-session -d -s gpt-search
    # run gpts-search-command in gpt-search tmux session
    tmux send-keys -t gpt-search "~/non-work/scripting/gpt-search/double-search.sh" C-m
    tmux attach-session -t gpt-search
}
attach-to-general-session() {
    if tmux has-session -t general_session 2>/dev/null; then
        tmux send-keys -t general_session "tmux new-window; tmux set-window-option remain-on-exit off" C-m	
        # Attach to the existing session
        tmux attach-session -t general_session
	
    else
        # Create a new session if it doesn't exist
        tmux new-session -s general_session
    fi
}

