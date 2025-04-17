#!/usr/bin/env bash

if ! command -v docker >/dev/null; then
    echo "==> \`docker\` is required to spawn the MinIO server"
fi

docker container stop minio-cluster >/dev/null || true
docker container rm minio-cluster >/dev/null || true

docker run -d                                \
    -p 9000:9000                             \
    -p 9001:9001                             \
    --name minio-cluster                     \
    -e MINIO_ACCESS_KEY="somedummyaccesskey" \
    -e MINIO_SECRET_KEY="somedummysecretkey" \
    minio/minio:RELEASE.2025-04-08T15-41-24Z server /data --console-address ":9001" --address ":9000"
