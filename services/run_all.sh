#!/bin/bash
set -e

SESSION="services"
tmux new-session -d -s $SESSION

tmux send-keys "cd services/gateway && python main.py" C-m
tmux split-window -v
tmux send-keys "cd services/auth_service && python main.py" C-m
tmux split-window -v
tmux send-keys "cd services/user_ingest_service && python main.py" C-m
tmux split-window -v
tmux send-keys "cd services/health_service && python main.py" C-m
tmux split-window -v
tmux send-keys "cd services/geolocation_service && python main.py" C-m
tmux split-window -v
tmux send-keys "cd services/recommendations_service && python main.py" C-m
tmux split-window -v
tmux send-keys "cd services/document_service && python main.py" C-m
tmux split-window -v
tmux send-keys "cd services/prediction_service && python main.py" C-m

tmux select-layout tiled
tmux attach-session -t $SESSION
