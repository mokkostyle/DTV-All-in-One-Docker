# --- Stage: Builder ---
FROM dtv-build-common-builder AS builder
ARG CACHEBUST=1

# ソースコードの取得
ARG CACHEBUST=1
RUN git clone --recursive https://github.com/kazuki0824/recisdb-rs.git /tmp/recisdb-rs

WORKDIR /tmp/recisdb-rs

# ビルド実行
RUN cargo build -F dvb --release
RUN cp -a target/release/recisdb /usr/local/bin/recisdb

# RUN cargo install -F dvb --path recisdb-rs
# --- DESTDIR方式の再現 ---
# 成果物集約用のディレクトリ構造を作成し、バイナリを配置
RUN mkdir -p /tmp/build_root/usr/local/bin && \
    cp -a target/release/recisdb /tmp/build_root/usr/local/bin/

# --- 書き出し用エントリーポイント ---
# JSON形式。ディレクトリ構造を保って ./dist に書き出します。
ENTRYPOINT ["/bin/sh", "-c", "mkdir -p /out && cp -a /tmp/build_root/. /out/ && chmod -R 777 /out/ && chmod -R 777 /out/"]