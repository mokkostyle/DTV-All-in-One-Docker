#!/bin/bash
# update.sh - コンテナの再構築と起動
echo "Updating and restarting Docker containers..."
# --build オプションでイメージを再構築し、最新の状態に更新
docker compose build --no-cache
docker compose up -d
echo "Update complete."
echo "All services are up to date and running."
exit 0  # 正常終了