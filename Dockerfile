# Gunakan image Go resmi
FROM golang:1.22 AS builder

WORKDIR /app

# Copy semua file module dan download dependency
COPY go.mod go.sum ./
RUN go mod download

# Copy semua source code
COPY . .

# Build REST server
RUN go build -o rest_server ./cmd/rest/main.go

# Stage final image
FROM gcr.io/distroless/base-debian12

WORKDIR /app
COPY --from=builder /app/rest_server .

# Port untuk REST (ubah kalau beda)
EXPOSE 8080

CMD ["./rest_server"]
