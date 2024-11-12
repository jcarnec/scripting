tmux new-session -A -d -s "kmonad"
tmux send-keys -t kmonad "~/non-work/kmonad/kmonad ~/non-work/kmonad/my-config.kbd" c-m;
