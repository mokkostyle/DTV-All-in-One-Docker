#!/bin/sh
set -e


# --- 書き出し用エントリーポイント ---
mkdir -p /out
cp -a /tmp/build_root/. /out/
chmod -R 777 /out/