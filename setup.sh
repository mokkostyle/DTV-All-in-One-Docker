#!/bin/bash
# init.sh - ディレクトリ作成、空ファイル初期化、環境構築

echo "Initializing environment..."

# 必要なディレクトリの作成
mkdir -p ./conf/edcb ./conf/mirakurun ./conf/konomitv ./conf/scan_result
mkdir -p ./dist/var/local/edcb/Setting ./dist/scan_result
mkdir -p ./data/edcb/EpgData ./data/edcb/LogoData ./data/mirakurun ./data/konomitv ./logs/konomitv

# 空ファイルの生成 (既存のファイルを上書きしないよう 'touch' または '>>' を使用)
# これにより、Dockerがディレクトリとして誤作成するのを防ぎます
touch ./conf/konomitv/config.yaml
touch ./conf/edcb/EpgTimerSrv.ini
touch "./conf/edcb/BonDriver_mirakc(LinuxMirakc).ChSet4.txt"
touch ./conf/edcb/ChSet5.txt
touch ./conf/edcb/HttpPublic.ini
touch ./conf/mirakurun/channels.yml
touch ./conf/mirakurun/tuners.yml
touch ./conf/mirakurun/server.yml

echo "Starting Docker Compose..."

# 1コマンドですべてを完結
# --build を付けることで、ソース変更時も確実に反映させます
docker compose up -d --build