# Stage 1: Build
FROM golang:1.22-alpine AS builder
WORKDIR /app

# Install git (buat ambil module)
RUN apk add --no-cache git

# Copy go mod & sum dulu biar cache build aman
COPY go.mod go.sum ./
RUN go mod download

# Copy seluruh project
COPY . .

# Build grpc server
RUN go build -o /grpc-server ./cmd/grpc/main.go
# Build rest server
RUN go build -o /rest-server ./cmd/rest/main.go

# Stage 2: Run
FROM alpine:latest
WORKDIR /app

# Install CA certificates (biar https jalan)
RUN apk add --no-cache ca-certificates

# Copy hasil build dari stage 1
COPY --from=builder /app/grpc-server .
COPY --from=builder /app/rest-server .

# Expose port default (sesuaikan sama service)
EXPOSE 50052 8080

# Default jalankan REST server
CMD ["./rest-server"]
