# Stage 1: Build semua binary Go
FROM golang:1.22-alpine AS builder

RUN apk add --no-cache git build-base

WORKDIR /app

# Copy go.mod dan go.sum dulu
COPY go.mod go.sum ./

# Download dependencies
RUN go mod tidy && go mod download

# Baru copy semua source
COPY . .

# Build binary
RUN go build -o /app/grpc_server ./cmd/grpc/main.go
RUN go build -o /app/rest_server ./cmd/rest/main.go
RUN go install github.com/improbable-eng/grpc-web/go/grpcwebproxy@latest
