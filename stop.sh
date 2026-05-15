#! /bin/bash

if [ ! -f dashboard.pid ]; then
  echo "No PID file found."
  exit 1
fi

PID=$(cat dashboard.pid)
echo "Stopping dashboard with PID ${PID}"

kill ${PID}

rm dashboard.pid
echo "Dashboard stopped."
