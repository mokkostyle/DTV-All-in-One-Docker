# -----------------------------------------------------------------------------
# ステージ1: サードパーティーライブラリのダウンロード
# -----------------------------------------------------------------------------
FROM dtv-build-common-builder AS thirdparty-downloader
ARG CACHEBUST=1

# /thirdparty フォルダを確実にルート直下に作成して展開する
WORKDIR /
RUN aria2c -x10 https://github.com/tsukumijima/KonomiTV/releases/download/v0.13.0/thirdparty-linux.tar.xz && \
    tar xvf thirdparty-linux.tar.xz

# -----------------------------------------------------------------------------
# ステージ2: クライアントのビルド (Node.js)
# -----------------------------------------------------------------------------
FROM dtv-build-common-builder AS client-builder
WORKDIR /code
RUN git clone --recursive https://github.com/tsukumijima/KonomiTV.git .
WORKDIR /code/client
RUN yarn install && yarn build
# -----------------------------------------------------------------------------
# ステージ3: サーバー環境の構築と集約
# -----------------------------------------------------------------------------
FROM dtv-build-common-builder AS builder
RUN mkdir -p /tmp/build_root/code

# 1. ソースコードの取得
WORKDIR /tmp/konomitv_git
RUN git clone --recursive https://github.com/tsukumijima/KonomiTV.git .

# 2. 成果物のコピー
RUN cp -r server /tmp/build_root/code/server && \
    cp config.example.yaml /tmp/build_root/code/config.example.yaml && \
    cp config.example.yaml /tmp/build_root/code/config.yaml && \
    cd /tmp/build_root/code/ && \
    sed -i '/E:\\TV-Record/d' ./config.yaml && \
    sed -i '/E:\\TV-Capture/d' ./config.yaml 

# 3. サードパーティーライブラリを配置 (パスを /thirdparty/ に修正)
COPY --from=thirdparty-downloader /thirdparty/ /tmp/build_root/code/server/thirdparty/

# 4. ビルド済みクライアントを配置
COPY --from=client-builder /code/client/dist/ /tmp/build_root/code/client/dist/

# --- 書き出し用エントリーポイント ---
ENTRYPOINT ["/bin/sh", "-c", "mkdir -p /out && cp -a /tmp/build_root/. /out/ && chmod -R 777 /out/"]