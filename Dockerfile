# ===== Stage 1: Build =====
FROM golang:1.21-alpine AS builder

# Install bash dan git (biar go mod download aman)
RUN apk add --no-cache bash git

# Set working dir
WORKDIR /app

# Copy go.mod & go.sum dulu biar cache build efisien
COPY go.mod go.sum ./
RUN go mod download

# Copy semua source code
COPY . .

# Build REST server
RUN go build -o rest_server ./cmd/rest/main.go

# Build gRPC server
RUN go build -o grpc_server ./cmd/grpc/main.go

# Install grpcwebproxy
RUN wget https://github.com/improbable-eng/grpc-web/releases/download/v0.15.0/grpcwebproxy-v0.15.0-linux-x86_64.zip \
    && unzip grpcwebproxy-v0.15.0-linux-x86_64.zip \
    && mv dist/grpcwebproxy /usr/local/bin/grpcwebproxy \
    && chmod +x /usr/local/bin/grpcwebproxy

# ===== Stage 2: Run =====
FROM alpine:latest

# Install CA certificates (biar HTTPS jalan)
RUN apk add --no-cache ca-certificates bash

WORKDIR /app

# Copy hasil build dari stage builder
COPY --from=builder /app/rest_server .
COPY --from=builder /app/grpc_server .
COPY --from=builder /usr/local/bin/grpcwebproxy /usr/local/bin/grpcwebproxy

# Expose ports (REST = 8080, gRPC = 50052, gRPC-WebProxy = 8081)
EXPOSE 8080 50052 8081

# Jalankan semua service
CMD sh -c "./grpc_server & ./rest_server & grpcwebproxy --backend_addr=localhost:50052 --server_bind_address=0.0.0.0 --server_http_debug_port=8081 --run_tls_server=false --backend_max_call_recv_msg_size=577659248 --allow_all_origins"
