#!/bin/sh
set -eu

ATTEMPTS=0
MAX_ATTEMPTS=20

until alembic upgrade head; do
  ATTEMPTS=$((ATTEMPTS + 1))
  if [ "$ATTEMPTS" -ge "$MAX_ATTEMPTS" ]; then
    echo "Alembic migration failed after $ATTEMPTS attempts."
    exit 1
  fi
  echo "Database not ready yet. Retrying migrations in 3s..."
  sleep 3
done

exec uvicorn app.main:app --host 0.0.0.0 --port 8080
