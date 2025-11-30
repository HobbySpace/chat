# Dockerfile для сборки tinode-db (инициализатор БД)
FROM golang:1.23-alpine AS builder

# Установка зависимостей для сборки
# postgresql-dev нужен для сборки с CGO_ENABLED=1 и тегом postgres
RUN apk add --no-cache git make gcc musl-dev postgresql-dev

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
# Сохраняем бинарник с другим именем, чтобы избежать конфликта с директорией
RUN cd tinode-db && \
    CGO_ENABLED=1 go build -tags postgres \
    -o /build/tinode-db-bin .

# Финальный образ
FROM alpine:3.22

# Установка необходимых пакетов
# postgresql-libs нужен для бинарника, собранного с CGO_ENABLED=1 и тегом postgres
# binutils нужен для ldd и readelf для диагностики
RUN apk add --no-cache ca-certificates bash gettext postgresql-libs binutils

WORKDIR /app

# Копируем собранный бинарник с правами на выполнение
COPY --from=builder --chmod=755 /build/tinode-db-bin /app/tinode-db

# Дополнительно убеждаемся, что файл исполняемый
RUN chmod +x /app/tinode-db

# Копируем entrypoint скрипт
# Контекст сборки - корень проекта, поэтому путь относительно него
COPY docker/hobbyspace-chat/dbinit/entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]

