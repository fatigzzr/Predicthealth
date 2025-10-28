#!/bin/bash
set -e

SESSION="services"
tmux new-session -d -s $SESSION -n gateway "cd services/gateway && python main.py"

tmux new-window -t $SESSION:1 -n auth "cd services/auth_service && python main.py"
tmux new-window -t $SESSION:2 -n user_ingest "cd services/user_ingest_service && python main.py"
tmux new-window -t $SESSION:3 -n health "cd services/health_service && python main.py"
tmux new-window -t $SESSION:4 -n geolocation "cd services/geolocation_service && python main.py"
tmux new-window -t $SESSION:5 -n recommendations "cd services/recommendations_service && python main.py"
tmux new-window -t $SESSION:6 -n document "cd services/document_service && python main.py"
tmux new-window -t $SESSION:7 -n prediction "cd services/prediction_service && python main.py"

echo "All services launched in tmux session '$SESSION'."
echo "Attach with: tmux attach -t $SESSION"
