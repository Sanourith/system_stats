#! /bin/bash

echo "Starting dashboard..."

python3 dashboard.py > logs/dashboard.log 2>&1 &

echo $1 > dashboard.pid
echo "Dashboard started with PID $(cat dashboard.pid)"
