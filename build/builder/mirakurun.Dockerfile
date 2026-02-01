# --- Stage: Builder ---
FROM dtv-build-common-builder AS builder
ARG CACHEBUST=1

ENV DOCKER=YES NODE_ENV=production
RUN mkdir -p /tmp/build_root/usr/local/lib/node_modules/mirakurun
# ソースの取得
RUN git clone --recursive https://github.com/Chinachu/Mirakurun.git /tmp/mirakurun
WORKDIR /tmp/mirakurun

# npmによるビルド
# 依存関係の解決とTSのコンパイル
RUN npm ci --include=dev && \
    npm run build && \
    npm ci --omit=dev

# --- DESTDIR方式の再現 ---
RUN cp -a . /tmp/build_root/usr/local/lib/node_modules/mirakurun/

# 実行用のシンボリックリンク作成
RUN mkdir -p /tmp/build_root/usr/local/bin 
RUN mkdir -p /tmp/build_root/usr/local/etc/mirakurun/
# ラッパースクリプトの作成
RUN printf '#!/bin/bash\n cd /usr/local/lib/node_modules/mirakurun\n exec node --max-semi-space-size=64 -r source-map-support/register /usr/local/lib/node_modules/mirakurun/lib/server.js "$@"\n' > /usr/local/bin/mirakurun-server \
&& chmod +x /usr/local/bin/mirakurun-server
RUN cp -a /usr/local/bin/mirakurun-server /tmp/build_root/usr/local/bin/mirakurun-server
RUN tee /tmp/build_root/usr/local/lib/node_modules/mirakurun/config/server.yml << 'EOT'
# logLevel: <number>
logLevel: 2

# path: <string>
path: /var/run/mirakc.sock

# port: <number>
# You can change this if port conflicted.
# Don't expose this port on the internet, not even with NAPT.
# Use this in LAN or VPN.
# `~` to disable TCP port listening.
port: 40772

EOT
# --- 書き出し用エントリーポイント ---
ENTRYPOINT ["/bin/sh", "-c", "mkdir -p /out && cp -a /tmp/build_root/. /out/ && chmod -R 777 /out/ && chmod -R 777 /out/ && chmod -R 777 /out/"]