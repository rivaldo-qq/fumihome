FROM golang:1.23 AS builder

WORKDIR /app

# Copy go.mod dan go.sum lalu download dependency
COPY go.mod go.sum ./
RUN go mod download

# Install protoc dan plugin Go
RUN apt-get update && apt-get install -y protobuf-compiler
RUN go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
RUN go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

# Copy semua source code
COPY . .

# Generate file proto
RUN protoc --go_out=./pb --go-grpc_out=./pb --proto_path=./proto \
    --go_opt=paths=source_relative \
    --go-grpc_opt=paths=source_relative service/service.proto

# Build REST
RUN go build -o ./bin/rest ./cmd/rest/main.go

# Build gRPC
RUN go build -o ./bin/grpc ./cmd/grpc/main.go

# Stage final image
FROM gcr.io/distroless/base-debian12
COPY --from=builder /app/bin /bin
COPY start.sh /bin/start.sh
WORKDIR /bin

RUN chmod +x /bin/start.sh

CMD ["./start.sh"]
