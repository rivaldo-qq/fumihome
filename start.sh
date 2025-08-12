#!/bin/sh

# Jalankan gRPC server di background
./grpc &

# Jalankan REST server di foreground
./rest
