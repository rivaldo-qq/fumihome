# Gunakan image Go resmi
FROM golang:1.21 AS builder

# Set working directory
WORKDIR /app

# Copy semua file ke dalam container
COPY . .

# Download dependencies
RUN go mod tidy

# Build REST server
RUN go build -o ./bin/rest_server ./cmd/rest/main.go

# Build gRPC server
RUN go build -o ./bin/grpc_server ./cmd/grpc/main.go

# Gunakan image yang lebih kecil untuk menjalankan
FROM debian:bookworm-slim

WORKDIR /app

# Copy binary dari tahap build
COPY --from=builder /app/bin/rest_server .
COPY --from=builder /app/bin/grpc_server .

# Port default (sesuaikan sama program lu)
EXPOSE 8080 50052

# Jalankan REST server (bisa diubah ke grpc_server kalau mau)
CMD ["./rest_server"]
