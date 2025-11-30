# Dockerfile для сборки Tinode сервера
FROM golang:1.23-alpine AS builder

# Установка зависимостей для сборки
RUN apk add --no-cache git make gcc musl-dev

# Разрешаем Go автоматически скачивать нужную версию инструментария
ENV GOTOOLCHAIN=auto

WORKDIR /build

# Копируем go.mod и go.sum для кэширования зависимостей
COPY go.mod go.sum ./
RUN go mod download

# Копируем весь исходный код
COPY . .

# Собираем сервер с поддержкой PostgreSQL
RUN cd server && \
    CGO_ENABLED=1 go build -tags postgres \
    -ldflags "-X main.buildstamp=$(date -u '+%Y%m%dT%H:%M:%SZ')" \
    -o /build/tinode .

# Финальный образ
FROM alpine:3.22

# Установка необходимых пакетов
RUN apk add --no-cache ca-certificates bash gettext

WORKDIR /app

# Копируем собранный бинарник
COPY --from=builder /build/tinode ./tinode

# Делаем исполняемым
RUN chmod +x ./tinode

# Создаем директории для загрузок и статического контента
RUN mkdir -p ./uploads ./static

# Скрипт для подстановки переменных окружения и запуска
RUN echo '#!/bin/sh' > /app/entrypoint.sh && \
    echo 'set -e' >> /app/entrypoint.sh && \
    echo 'echo "Substituting environment variables in config..."' >> /app/entrypoint.sh && \
    echo 'envsubst < /app/server.conf.template > /app/server.conf' >> /app/entrypoint.sh && \
    echo 'echo "Starting Tinode server..."' >> /app/entrypoint.sh && \
    echo './tinode -config=/app/server.conf' >> /app/entrypoint.sh && \
    chmod +x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]

# Порты: HTTP/WebSocket и gRPC
EXPOSE 6060 16060

