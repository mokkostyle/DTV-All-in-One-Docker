#!/bin/bash
mkdir -p /tmp/scan
cd /tmp/scan

# --- スキャン実行セクション ---
if [ ! -s /var/local/edcb/Setting/ChSet5.txt.tmp ]; then
    # 生成されるまでループ
    while [ ! -s /tmp/scan/Mirakurun/tuners.yml ]; do
        echo "ファイルを待機中、またはスキャンを試行中..."
        ISDBScanner --lnb 15v /tmp/scan || true
        sleep 1
    done
else
    echo "既存のスキャン結果が存在します。スキャンをスキップします。"
    exit 0
fi

echo "スキャンが成功し、生成されたファイルを加工します。"

# --- Mirakurun/tuners.yml の加工セクション ---
TUNERS_YML="/tmp/scan/Mirakurun/tuners.yml"
if [ -f "$TUNERS_YML" ]; then
    echo "Processing $TUNERS_YML..."
    # BOM削除、改行コード変換、フォーマット調整を一括で行う
    sed -E \
        -e '1s/^\xef\xbb\xbf//' \
        -e 's/\r//g' \
        -e '/recisdb tune/ s/(<channel>)\s*(<satellite>)\s*-/\1 \2 -/g' \
        -e ':a; /recisdb tune.*<channel>\s*$/ { N; s/(<channel>)\s*\n\s*(<satellite>)/\1 \2/; ba; }' \
        "$TUNERS_YML" > /tmp/tuners.yml.tmp
    
    mv /tmp/tuners.yml.tmp "$TUNERS_YML"
    mkdir -p /usr/local/etc/mirakurun
    cp -a /tmp/scan/Mirakurun/*.yml /usr/local/etc/mirakurun/
    cp -a /usr/local/lib/node_modules/mirakurun/config/server.yml /usr/local/etc/mirakurun/
    cd /usr/local/lib/node_modules/mirakurun
    node --max-semi-space-size=64 -r source-map-support/register lib/server.js > /dev/null 2>&1 &
    until curl -s http://localhost:40772/api/docs > /dev/null; do
        echo -e "[SYSTEM] Waiting for Mirakurun API..."
        sleep 2
    done
    echo "Mirakurun API is available."
    /var/local/edcb/EpgTimerSrv > /dev/null 2>&1 &
    sleep 2
    echo "Starting channel scan with EpgDataCap_Bon..."
    if [ ! -s /var/local/edcb/Setting/BonDriver_mirakc\(LinuxMirakc\).ChSet4.txt.tmp ]; then
        # チャンネルスキャンの実行
        EpgDataCap_Bon -d BonDriver_mirakc.so -chscan
        TARGET_FILE='/var/local/edcb/Setting/BonDriver_mirakc(LinuxMirakc).ChSet4.txt'
        cp -a "$TARGET_FILE" /tmp/scan/EDCB-Wine/BonDriver_mirakc\(LinuxMirakc\).ChSet4.txt
        TARGET_FILE='/var/local/edcb/Setting/ChSet5.txt'
        cp -a "$TARGET_FILE" /tmp/scan/EDCB-Wine/ChSet5.txt
    fi
fi

# --- 最終出力セクション ---
echo "完了。結果を /out にコピーします。"
mkdir -p /out
# パーミッション設定
chmod -R 777 /tmp/scan
chmod -R 777 /out/

# cp -a で上書きコピー
cp -a /tmp/scan/* /out/

exit 0