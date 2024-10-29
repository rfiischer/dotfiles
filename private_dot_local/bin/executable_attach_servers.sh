# Partially created with ChatGPT

# Function to check for tmux sessions on remote server
check_remote_tmux_session() {
    SERVER=$1
    timeout 10s ssh -n -o ConnectTimeout=5 $SERVER "tmux ls" 2>/dev/null
}

# Name of the local tmux session
LOCAL_TMUX_SESSION="servers"
DOMAIN=".cel.kit.edu"
USER="fischer"

# Start a new tmux session if it doesn't already exist
tmux has-session -t "$LOCAL_TMUX_SESSION" 2>/dev/null
if [ $? != 0 ]; then
    tmux new-session -d -s "$LOCAL_TMUX_SESSION"

    # Check if the server list file exists
    if test -f ./.cel_machines; then
        # Loop on all machines 
        while read -r SERVER_LINE; do
            NAME=$(echo "$SERVER_LINE" | awk -F '[:,]' '{print tolower($1)}' | xargs)
            SERVER=${USER}@${NAME}${DOMAIN}    	
            TMUX_SESSIONS=$(check_remote_tmux_session $SERVER)

            if [[ $? -eq 0 ]]; then
            echo "Found tmux session(s) on $SERVER: $TMUX_SESSIONS"
        
            # Open a new window in the local tmux session
            tmux new-window -t "$LOCAL_TMUX_SESSION" -n "$NAME"
            tmux send-keys -t "$LOCAL_TMUX_SESSION:$NAME" "ssh $SERVER -t 'tmux attach'" C-m
            # "ssh -n $SERVER -t 'tmux attach || tmux new-session'"
            else
                echo "No tmux session(s) on $SERVER"
            fi
        done < ./.cel_machines
        
        Attach to the local session
        tmux a

    fi

else
    echo "There is already a servers session."
fi
