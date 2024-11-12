#!/bin/bash
sleep 0.1
i3-msg 'move container to workspace 8'
i3-msg 'workspace 8'
i3-msg 'floating enable'
# center the window
i3-msg 'resize set 800 800'
i3-msg 'move position center'
# Define the file to store the query
query_file="$HOME/.last_query"
past_query=$(cat $query_file)

# Open the query file in Vim 
vim $query_file;
# move this window to workspace 9 and make it floating

# Read the query from the file
query=$(cat "$query_file")

# Check if query is empty
if [ -z "$query" ]; then
    i3-msg 'kill'
    exit 1
fi

# Check if the query is the same as the last one
if [ "$query" = "$past_query" ]; then
    i3-msg 'kill'
    exit 1
fi

#move the window to scratchpad
i3-msg 'move scratchpad'
# Kill containers on workspace 9 and 8
i3-msg 'workspace 9; kill'
i3-msg 'workspace 8; kill'

# URL encode the query
encoded_query=$(echo "$query" | jq -sRr @uri)

# Define the URLs for Google and ChatGPT searches
google_url="https://www.google.com/search?q=$encoded_query"
chatgpt_search_url="https://chat.openai.com/?q=$encoded_query&hints=search&ref=ext&temporary-chat=true"
chatgpt_url="https://chat.openai.com/?q=$encoded_query&ref=ext&temporary-chat=true"

# Open Google search in Chromium on workspace 8 (nohup to detach from terminal)
nohup chromium "$google_url" --new-window > /dev/null 2>&1 &
sleep 0.3  # Wait for the window to appear

# Open ChatGPT searches on workspace 9 without focusing on it (nohup to detach)
nohup chromium "$chatgpt_url" --new-window > /dev/null 2>&1 &
sleep 0.3  # Wait for the window to appear
i3-msg 'border pixel 20'

# Move only the last opened ChatGPT search window to workspace 9
i3-msg 'move container to workspace 9'

# Open another ChatGPT search window on workspace 9 (nohup to detach)
nohup chromium "$chatgpt_search_url" --new-window > /dev/null 2>&1 &
sleep 0.3  # Wait for the window to appear
i3-msg 'move container to workspace 9'
