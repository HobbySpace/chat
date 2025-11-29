# Dockerfile для сборки tinode-db (инициализатор БД)
FROM golang:1.23-alpine AS builder

# Установка зависимостей для сборки
RUN apk add --no-cache git make gcc musl-dev

# Разрешаем Go автоматически скачивать нужную версию инструментария
ENV GOTOOLCHAIN=auto

WORKDIR /build

# Копируем go.mod и go.sum для кэширования зависимостей
COPY go.mod go.sum ./
RUN go mod download

# Копируем исходный код tinode-db
COPY tinode-db ./tinode-db
COPY server ./server
COPY pbx ./pbx

# Собираем tinode-db с поддержкой PostgreSQL
RUN cd tinode-db && \
    CGO_ENABLED=1 go build -tags postgres \
    -o /build/tinode-db .

# Финальный образ
FROM alpine:3.22

# Установка необходимых пакетов
RUN apk add --no-cache ca-certificates bash gettext

WORKDIR /app

# Копируем собранный бинарник
COPY --from=builder /build/tinode-db ./tinode-db

# Делаем исполняемым
RUN chmod +x ./tinode-db

# Скрипт для подстановки переменных окружения и запуска
# Используем printf для правильной обработки переменных (они подставляются при запуске)
RUN printf '#!/bin/sh\n' > /app/entrypoint.sh && \
    printf 'set -e\n' >> /app/entrypoint.sh && \
    printf 'echo "Substituting environment variables in config..."\n' >> /app/entrypoint.sh && \
    printf 'envsubst < /app/tinode_db.conf.template > /app/tinode_db.conf\n' >> /app/entrypoint.sh && \
    printf 'echo "Initializing database..."\n' >> /app/entrypoint.sh && \
    printf './tinode-db -config=/app/tinode_db.conf -add_root=root:"$ROOT_USER_PASSWORD"\n' >> /app/entrypoint.sh && \
    printf 'echo "Database initialization completed!"\n' >> /app/entrypoint.sh && \
    chmod +x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]

