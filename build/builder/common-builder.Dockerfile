# build/builder/common-builder.Dockerfile 修正版
FROM ubuntu:22.04 AS common-builder
ENV DEBIAN_FRONTEND=noninteractive

# 1. 基本ツールとC++/Rustビルド依存関係 (libclang-devを追加)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential cmake pkg-config git curl wget ca-certificates \
    libpcsclite-dev libdvbv5-dev liblua5.2-dev lua-zlib-dev libudev-dev \
    libssl-dev zlib1g-dev libncurses5-dev libncursesw5-dev libreadline-dev \
    libsqlite3-dev libgdbm-dev libdb5.3-dev libbz2-dev libexpat1-dev \
    liblzma-dev libffi-dev uuid-dev tar unzip xz-utils aria2 \
    libclang-dev clang \
    && rm -rf /var/lib/apt/lists/*

# 2. Rust インストール (PATHを確実に通す)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"
# rustのコンポーネントを最新に
RUN rustup update stable

# 3. Node.js 20 & Yarn (修正ポイント)
# Corepackを有効化して Yarn を利用可能にするのが現在の推奨方法です
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && corepack enable \
    && corepack prepare yarn@stable --activate

# 4. Python 3.12 (ISDBScanner用: ソースビルド) [cite: 7]
WORKDIR /tmp
RUN wget https://www.python.org/ftp/python/3.12.0/Python-3.12.0.tgz && \
    tar xzf Python-3.12.0.tgz && \
    cd Python-3.12.0 && \
    ./configure --enable-optimizations --enable-shared && \
    make -j "$(nproc)" && make install && ldconfig && \
    rm -rf /tmp/Python-3.12.0*

# 5. Poetry (ISDBScanner用) [cite: 8]
RUN curl -sSL https://install.python-poetry.org | python3 -
ENV PATH="/root/.local/bin:${PATH}"