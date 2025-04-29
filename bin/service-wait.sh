#!/bin/bash

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 host:port"
  exit 1
fi

HOST_PORT="$1"
HOST="${HOST_PORT%%:*}"
PORT="${HOST_PORT##*:}"

echo "⏳ Waiting for $HOST:$PORT..."

while ! nc -z "$HOST" "$PORT"; do
  sleep 1
done

echo "✅ $HOST:$PORT is available."
