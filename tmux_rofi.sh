#!/bin/bash

# -----------------------------------------------------------------------------
# Script: session_app_launcher.sh
# Description: Manage tmux sessions and applications with a unified rofi menu.
# Dependencies: tmux, rofi, xdotool, wmctrl, notify-send, gnome-terminal, firefox, discord, xournal
# -----------------------------------------------------------------------------

# Define your tmux sessions with their corresponding launch commands
# Format: "SessionName;LaunchCommand"
tmux_sessions=(
    "ml_session;~/non-work/scripting/session_definition_scripts/tmux_movie_list.sh"
    "general_session;~/non-work/scripting/session_definition_scripts/tmux_general_session.sh"
    # Add more sessions here in the format "SessionName;LaunchCommand"
    # Example:
    # "dev_session;/path/to/dev_session_start.sh"
)

# Define your applications with the format: "DisplayName;LaunchCommand;WindowSearchString"
applications=(
    "ChatGPT;firefox --new-window https://chat.openai.com;ChatGPT"
    "Discord;firefox --new-window https://discord.com;Discord"
    "Xournal;xournal;Xournal123"
    "Code;code;Visual Studio Code"
    # Add more applications here in the format "DisplayName;LaunchCommand;WindowSearchString"
)

# Arrays to store window menu entries and corresponding window IDs
declare -a window_menu_entries
declare -a window_ids

# Function to get active tmux session names
get_active_tmux_sessions() {
    tmux ls 2>/dev/null | awk -F: '{print $1}'
}

# Function to retrieve all predefined tmux sessions
get_predefined_tmux_sessions() {
    for session in "${tmux_sessions[@]}"; do
        IFS=";" read -r session_name launch_cmd <<< "$session"
        echo "$session_name"
    done
}

# Function to combine active and predefined tmux sessions, removing duplicates
get_all_tmux_sessions() {
    local active_sessions
    active_sessions=$(get_active_tmux_sessions)
    local predefined_sessions
    predefined_sessions=$(get_predefined_tmux_sessions)
    echo -e "${active_sessions}\n${predefined_sessions}" | sort -u
}

# Function to get all application display names
get_application_names() {
    for app in "${applications[@]}"; do
        IFS=";" read -r display_name launch_cmd window_search <<< "$app"
        echo "$display_name"
    done
}

# Function to retrieve the launch command for a given tmux session
get_tmux_launch_command() {
    local session_name="$1"
    for session in "${tmux_sessions[@]}"; do
        IFS=";" read -r name launch_cmd <<< "$session"
        if [ "$name" == "$session_name" ]; then
            echo "$launch_cmd"
            return
        fi
    done
    echo ""
}

# Function to launch or focus a tmux session
handle_tmux_session() {
    local session="$1"

    # Check if the tmux session is already running
    if ! tmux has-session -t "$session" 2>/dev/null; then
        # Retrieve the launch command for the session
        local launch_cmd
        launch_cmd=$(get_tmux_launch_command "$session")

        if [ -n "$launch_cmd" ]; then
            # Execute the launch command
            eval "$launch_cmd" &
            # Wait briefly to allow the session to start
            sleep 2
        else
            notify-send "No launch command found for tmux session: $session, $launch_cmd"
            return 1
        fi
    fi

    # # Check if a gnome-terminal window with the session name exists
    local window_id
    window_id=$(xdotool search --name "$session" | head -n 1)

    if [ -n "$window_id" ]; then
        # Focus the existing window
        wmctrl -i -a "$window_id"
    else
        # Open a new terminal and attach to the tmux session
        gnome-terminal --title="$session" -- tmux attach-session -t "$session" &

        # Wait briefly to allow the terminal to open
        sleep 0.5

        # Attempt to focus the new window
        window_id=$(xdotool search --name "$session" | head -n 1)
        if [ -n "$window_id" ]; then
            wmctrl -i -a "$window_id"
        else
            notify-send "Failed to open tmux session: $session"
        fi
    fi
}

# Function to launch or focus an application
handle_application() {
    local app_display_name="$1"
    local launch_cmd
    local window_search

    # Retrieve the launch command and window search string for the application
    for app in "${applications[@]}"; do
        IFS=";" read -r display_name cmd win_search <<< "$app"
        if [ "$display_name" == "$app_display_name" ]; then
            launch_cmd="$cmd"
            window_search="$win_search"
            break
        fi
    done

    if [ -z "$launch_cmd" ] || [ -z "$window_search" ]; then
        notify-send "Invalid application configuration for: $app_display_name"
        return 1
    fi

    # Check if the application window is already open
    local window_id
    window_id=$(xdotool search --name "$window_search" | head -n 1)

    if [ -n "$window_id" ]; then
        # Focus the existing window
        wmctrl -i -a "$window_id"
    else
        # Launch the application
        eval "$launch_cmd" &

        # Wait briefly to allow the application to open
        sleep 1

        # Attempt to focus the new window
        window_id=$(xdotool search --name "$window_search" | head -n 1)
        if [ -n "$window_id" ]; then
            wmctrl -i -a "$window_id"
        else
            # notify-send "Failed to launch application: $app_display_name"
            sleep 1
        fi
    fi
}

# Function to get all application display names
get_application_display_names() {
    get_application_names
}

# Function to get all active windows
get_active_windows() {
    local index=0
    while read -r line; do
        window_id=$(echo "$line" | awk '{print $1}')
        window_title=$(echo "$line" | cut -d ' ' -f 4-)
        menu_entry="WINDOW: $window_title"
        window_menu_entries[$index]="$menu_entry"
        window_ids[$index]="$window_id"
        ((index++))
    done < <(wmctrl -l)
}

# Function to focus a window
handle_window() {
    local window_id="$1"
    if [ -n "$window_id" ]; then
        # Focus the window
        wmctrl -i -a "$window_id"
    else
        notify-send "Invalid window ID: $window_id"
    fi
}

# Function to display the rofi menu and handle selection
select_and_launch() {
    local menu_entries=()
    local menu_actions=()
    local index=0

    # Get applications
    app_names=$(get_application_display_names)
    while IFS= read -r app; do
        menu_entries[$index]="$index APP: $app"
        menu_actions[$index]="application:$app"
        ((index++))
    done <<< "$app_names"


    # Get tmux sessions
    tmux_sessions_=$(get_all_tmux_sessions)
    while IFS= read -r session; do
        menu_entries[$index]="$index TMUX: $session"
        menu_actions[$index]="tmux_session:$session"
        ((index++))
    done <<< "$tmux_sessions_"


    # Get active windows
    get_active_windows
    for ((i=0; i<${#window_menu_entries[@]}; i++)); do
        menu_entries[$index]="$index ${window_menu_entries[$i]}"
        menu_actions[$index]="window:${window_ids[$i]}"
        ((index++))
    done

    # Present the menu
    selected=$(printf "%s\n" "${menu_entries[@]}" | rofi -dmenu -p "Select tmux session, Application, or Window")

    if [ -z "$selected" ]; then
        exit 0
    fi

    # Find the index of the selected menu entry
    local action=""
    for ((i=0; i<${#menu_entries[@]}; i++)); do
        if [ "${menu_entries[$i]}" == "$selected" ]; then
            action="${menu_actions[$i]}"
            break
        fi
    done

    if [ -z "$action" ]; then
        notify-send "Unknown selection: $selected"
        exit 1
    fi

    # Process the action
    case "$action" in
        tmux_session:*)
            session_name="${action#tmux_session:}"
            handle_tmux_session "$session_name"
            ;;
        application:*)
            app_name="${action#application:}"
            handle_application "$app_name"
            ;;
        window:*)
            window_id="${action#window:}"
            handle_window "$window_id"
            ;;
        *)
            notify-send "Unknown action: $action"
            exit 1
            ;;
    esac
}

# Main execution
select_and_launch
