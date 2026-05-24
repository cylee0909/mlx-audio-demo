#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HOST="${MLX_HOST:-localhost}"
PORT="${MLX_PORT:-8000}"

echo "=== MLX Audio TTS ==="
echo ""

# Clean up any existing process on the target port
OLD_PIDS=$(lsof -ti :"$PORT" 2>/dev/null || true)
if [ -n "$OLD_PIDS" ]; then
  echo "[0/2] Cleaning up port $PORT (PIDs: $OLD_PIDS)..."
  kill $OLD_PIDS 2>/dev/null
  sleep 1
  echo "       Port $PORT is now free."
fi

# Start the API server in the background
echo "[1/2] Starting API server on http://${HOST}:${PORT} ..."
python -m mlx_audio.server --host "$HOST" --port "$PORT" &
SERVER_PID=$!

# Wait for the server to be ready
echo "[2/2] Waiting for server to be ready..."
for i in $(seq 1 30); do
  if curl -s "http://${HOST}:${PORT}/" > /dev/null 2>&1; then
    echo "       Server is ready."
    break
  fi
  sleep 1
done

# Open the TTS UI in the default browser
HTML_PATH="$SCRIPT_DIR/tts.html"
if [ -f "$HTML_PATH" ]; then
  open "$HTML_PATH"
  echo "       TTS UI opened in browser."
else
  echo "       Warning: tts.html not found at $HTML_PATH"
fi

echo ""
echo "Press Ctrl+C to stop the server."

# Wait for the server process
trap "kill $SERVER_PID 2>/dev/null; exit 0" INT TERM
wait $SERVER_PID
