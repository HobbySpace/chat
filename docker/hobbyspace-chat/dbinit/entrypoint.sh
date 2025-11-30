#!/bin/sh
set -e

cd /app

echo "Substituting environment variables in config..."
envsubst < /app/tinode_db.conf.template > /app/tinode_db.conf

echo "Initializing database..."
# Запускаем tinode-db с подробным выводом
# Перенаправляем stderr в stdout, чтобы видеть все ошибки
/app/tinode-db -config=/app/tinode_db.conf -add_root=root:"$ROOT_USER_PASSWORD" 2>&1

exit_code=$?
if [ $exit_code -ne 0 ]; then
    echo "ERROR: tinode-db exited with code $exit_code"
    exit $exit_code
fi

echo "Database initialization completed!"

