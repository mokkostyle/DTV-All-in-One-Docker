# --- Stage: Builder ---
FROM dtv-build-common-builder AS builder
ARG CACHEBUST=1

RUN mkdir -p /tmp/build_root

# ソースの取得とビルド
RUN git clone https://github.com/tsukumijima/libaribb25.git /tmp/libaribb25
WORKDIR /tmp/libaribb25
RUN cmake -DCMAKE_INSTALL_PREFIX=/usr/local . && \
    make -j "$(nproc)" && \
    make install DESTDIR=/tmp/build_root

# --- 書き出し用エントリーポイント ---
ENTRYPOINT ["/bin/sh", "-c", "mkdir -p /out && cp -a /tmp/build_root/. /out/ && chmod -R 777 /out/"]