# --- ステージ1: 各コンポーネントのビルド ---
# FROM dtv-build-common-builder AS common-builder
# FROM dtv-build-libarib25 AS builder-libarib25
# FROM dtv-build-recisdb AS builder-recisdb
# FROM dtv-build-isdbscanner AS builder-isdbscanner
# FROM dtv-build-mirakurun AS builder-mirakurun
# FROM dtv-build-edcb AS builder-edcb
# FROM dtv-build-konomitv AS builder-konomitv
# FROM dtv-build-channel-scanner AS config-artifacts

# --- ステージ2: ランタイムイメージ ---
FROM nvidia/cuda:12.8.0-base-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Tokyo

# 1. 基礎ツールのインストール
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl git gpg tzdata psmisc procps \
    && rm -rf /var/lib/apt/lists/*

# 2. 外部リポジトリの追加 (1つずつ実行してエラーを回避)
# Intel GPU
RUN curl -fsSL https://repositories.intel.com/gpu/intel-graphics.key | gpg --yes --dearmor --output /usr/share/keyrings/intel-graphics-keyring.gpg && \
    echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/intel-graphics-keyring.gpg] https://repositories.intel.com/gpu/ubuntu jammy unified' > /etc/apt/sources.list.d/intel-gpu-jammy.list

# AMD GPU
RUN curl -fsSL https://repo.radeon.com/rocm/rocm.gpg.key | gpg --yes --dearmor --output /usr/share/keyrings/rocm-keyring.gpg && \
    echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/rocm-keyring.gpg] https://repo.radeon.com/amdgpu/6.4.4/ubuntu jammy main' > /etc/apt/sources.list.d/amdgpu.list && \
    echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/rocm-keyring.gpg] https://repo.radeon.com/amdgpu/6.4.4/ubuntu jammy proprietary' > /etc/apt/sources.list.d/amdgpu-proprietary.list && \
    echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/rocm-keyring.gpg] https://repo.radeon.com/rocm/apt/6.4.4 jammy main' > /etc/apt/sources.list.d/rocm.list

# Google Chrome
RUN curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | gpg --yes --dearmor --output /usr/share/keyrings/google-chrome-keyring.gpg && \
    echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome-keyring.gpg] https://dl.google.com/linux/chrome/deb/ stable main' > /etc/apt/sources.list.d/google-chrome.list

# Node.js (Nodesource)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash -

# 3. 全パッケージのインストール
# エラーが出るパッケージを特定しやすくするため、分けて記述します
RUN apt-get update && apt-get install -y --no-install-recommends \
    nodejs \
    google-chrome-stable fonts-vlgothic \
    libfontconfig1 libfreetype6 libfribidi0 \
    libpcsclite1 pcscd pcsc-tools iproute2 strace\
    # recisdb 用 (libdvbv5.so.0)
    libdvbv5-0 \
    # EDCB 用 (liblua5.2.so.0)
    liblua5.2-0 \
    # スマートカードリーダー用 (libpcsclite.so.1)
    libpcsclite1 \
    # その他、実行に必要な基本パッケージ
    ca-certificates \
    # NVIDIA関連 (baseイメージに足りない分)
    cuda-nvrtc-12-8 libnpp-12-8 \
    # Intel GPU関連
    intel-media-va-driver-non-free intel-opencl-icd libigfxcmrt7 libmfx1 libmfxgen1 libva-drm2 libva-x11-2 ocl-icd-opencl-dev \
    # AMD GPU関連 (エラーが出やすいので注意)
    amf-amdgpu-pro libamdenc-amdgpu-pro libdrm2-amdgpu ocl-icd-libopencl1 rocm-opencl-runtime vulkan-amdgpu-pro \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 構造を維持して一括コピーするのではなく、必要なものを必要な場所へ
COPY --from=dtv-build-libarib25 /tmp/build_root/. /
COPY --from=dtv-build-recisdb /tmp/build_root/. /
COPY --from=dtv-build-isdbscanner /tmp/build_root/. /
COPY --from=dtv-build-mirakurun /tmp/build_root/. /
COPY --from=dtv-build-edcb /tmp/build_root/. /
COPY --from=dtv-build-konomitv /tmp/build_root/. /

# 全バイナリをコピーした直後に実行
RUN ldconfig
# KonomiTV 依存関係の構築
WORKDIR /code/server
RUN /code/server/thirdparty/Python/bin/python -m poetry env use /code/server/thirdparty/Python/bin/python && \
    /code/server/thirdparty/Python/bin/python -m poetry install --only main --no-root

# Mirakurun の準備
RUN cd /usr/local/lib/node_modules/mirakurun && \
    npm install --production 
