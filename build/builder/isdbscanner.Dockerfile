# --- Stage: Builder ---
FROM dtv-build-common-builder AS builder
ARG CACHEBUST=1

RUN mkdir -p /tmp/build_root/usr/local/bin

# ソースの取得
RUN git clone --recursive https://github.com/tsukumijima/ISDBScanner.git /tmp/isdbscanner
WORKDIR /tmp/isdbscanner

# ビルド実行
RUN poetry env use /usr/local/bin/python3.12 && \
    poetry install --no-interaction && \
    poetry run pyinstaller --onefile --name ISDBScanner ./isdb_scanner/__main__.py

# 成果物の配置
RUN cp /tmp/isdbscanner/dist/ISDBScanner /tmp/build_root/usr/local/bin/

ENTRYPOINT ["/bin/sh", "-c", "mkdir -p /out && cp -a /tmp/build_root/. /out/ && chmod -R 777 /out/"]