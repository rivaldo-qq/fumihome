# Stage 1: Build semua binary Go
FROM golang:1.22-alpine AS builder

# Install git dan build tools
RUN apk add --no-cache git build-base

WORKDIR /app

# Copy go.mod dan go.sum
COPY go.mod go.sum ./



# Copy semua file source
COPY . .

# Build gRPC server
RUN go build -o /app/grpc_server ./cmd/grpc/main.go

# Build REST server
RUN go build -o /app/rest_server ./cmd/rest/main.go

# Install grpcwebproxy
RUN go install github.com/improbable-eng/grpc-web/go/grpcwebproxy@latest

# Stage 2: Final container
FROM alpine:latest

WORKDIR /root/

# Install bash & SSL tools (jika perlu)
RUN apk add --no-cache bash ca-certificates

# Copy binary dari builder
COPY --from=builder /app/grpc_server .
COPY --from=builder /app/rest_server .
COPY --from=builder /go/bin/grpcwebproxy .

# Expose ports
EXPOSE 50052 8080 9090

# Script untuk jalanin semua service
COPY start.sh .
RUN chmod +x start.sh

CMD ["./start.sh"]
