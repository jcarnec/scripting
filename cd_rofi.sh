cd_rofi() {
    selected_dir=$(find . -type d | rofi -dmenu -p "Select directory:") || return
    session_name=$(basename "$selected_dir")
    
    if [ -z "$selected_dir" ]; then
        echo "No directory selected."
        return 1
    fi
    
    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        tmux new-session -d -s "$session_name" -c "$selected_dir"
    fi
    
    gnome-terminal -- bash -c "tmux attach -t $session_name"
}

cd_rofi
