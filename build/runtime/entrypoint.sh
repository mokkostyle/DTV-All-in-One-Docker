#!/bin/bash
set -e

# --- 色の定義 ---
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'

COLOR_MIRAKC=$'\e[0;35m'    # マゼンタ
COLOR_EDCB_SRV=$'\e[0;36m'   # シアン
COLOR_EDCB_SCAN=$'\e[0;33m'  # イエロー
COLOR_KONOMI=$'\e[0;32m'    # グリーン
COLOR_SYSTEM=$'\e[0;34m'    # ブルー
RESET=$'\e[0m'

# --- 共通色付け関数 ---
colorize() {
    local color=$1
    local tag=$2
    shift 2
    
    # stdbuf でバッファリングを解除
    # sed の中で直接変数を展開。変数が $'\e' で定義されているので正しく色が付きます
    stdbuf -oL -eL "$@" 2>&1 | sed -u "s/^/${color}[${tag}] /;s/$/${RESET}/"
}

# --- 1. 準備フェーズ ---
ldconfig /usr/local/lib

# --- 2. カードリーダー準備 ---
if [ "$DISABLE_PCSCD" != "1" ]; then
    echo -e "${GREEN}[INFO]${RESET} Starting pcscd..."
    /etc/init.d/pcscd start || echo "Warning: pcscd start failed"
    sleep 1
fi

# --- 3. Mirakurun 起動 ---
echo -e "${GREEN}[INFO]${RESET} Mirakurun is starting..."
cd /usr/local/lib/node_modules/mirakurun
colorize "$COLOR_MIRAKC" "Mirakurun" node --max-semi-space-size=64 -r source-map-support/register lib/server.js &

until curl -s http://localhost:40772/api/docs > /dev/null; do
    echo -e "${COLOR_SYSTEM}[SYSTEM] Waiting for Mirakurun API...${RESET}"
    sleep 2
done

# --- 4. EDCB 起動 ---
echo -e "${GREEN}[INFO]${RESET} Starting EpgTimerSrv..."
colorize "$COLOR_EDCB_SRV" "EDCB-SRV" /var/local/edcb/EpgTimerSrv &
sleep 2


# --- 5. KonomiTV 実行 (exec) ---
cd /code/server/
if [ ! -d /code/server/.venv ] ; then
    echo -e "${COLOR_SYSTEM}[SYSTEM] Setting up Python environment...${RESET}"
    /code/server/thirdparty/Python/bin/python -m poetry env use /code/server/thirdparty/Python/bin/python
    /code/server/thirdparty/Python/bin/python -m poetry install --only main --no-root
    sleep 2
fi

# --- 5. KonomiTV 実行 (exec) ---
echo -e "${COLOR_KONOMI}[INFO]${RESET} KonomiTV is starting with exec..."

# Python のバッファリング無効化
export PYTHONUNBUFFERED=1

# exec時も $'\e' で定義した変数を使うことで色が反映されます
exec stdbuf -oL -eL /code/server/.venv/bin/python KonomiTV.py 2>&1 | sed -u "s/^/${COLOR_KONOMI}[KonomiTV] /;s/$/${RESET}/"