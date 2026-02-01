# --- Stage: Builder ---
FROM dtv-build-common-builder AS builder
ARG CACHEBUST=1
RUN mkdir -p /tmp/build_root/
# 1. Luaライブラリのビルド
WORKDIR /tmp
RUN curl -L https://github.com/xtne6f/lua/archive/refs/heads/v5.2-luabinaries.tar.gz | tar xz \
    && cd lua-5.2-luabinaries \
    && make liblua5.2.so \
    && cp liblua5.2.so /usr/local/lib/liblua5.2.so \
    && ldconfig

RUN curl -L https://github.com/xtne6f/lua-zlib/archive/refs/heads/v0.5-lua52.tar.gz | tar xz \
    && cd lua-zlib-0.5-lua52 \
    && make libzlib52.so \
    && mkdir -p /usr/local/lib/lua/5.2 \
    && cp libzlib52.so /usr/local/lib/lua/5.2/libzlib52.so

# 2. EDCBのビルド
RUN git clone -b work-plus-s-251101 --depth=1 https://github.com/xtne6f/EDCB.git \
    && cd EDCB/Document/Unix \
    && make -j "$(nproc)" \
    && make install \
    && make extra -j "$(nproc)" \
    && make install_extra \
    && mkdir -p /var/local/edcb \
    && make setup_ini \
    && sed -i -e 's/^ALLOW_SETTING=.*/ALLOW_SETTING=true/' /var/local/edcb/HttpPublic/legacy/util.lua

# 3. WebUI & BonDriver
RUN git clone --depth=1 https://github.com/EMWUI/EDCB_Material_WebUI.git \
    && cp -r /tmp/EDCB_Material_WebUI/HttpPublic /var/local/edcb/ \
    && cp -r /tmp/EDCB_Material_WebUI/Setting /var/local/edcb/ \
    && git clone --depth=1 --recurse-submodules https://github.com/matching/BonDriver_LinuxMirakc.git \
    && cd BonDriver_LinuxMirakc \
    && make -j "$(nproc)" \
    # BonDriver_mirakc.so
    && cp BonDriver_LinuxMirakc.so /usr/local/lib/edcb/BonDriver_mirakc.so \
    && cp BonDriver_LinuxMirakc.so.ini_sample /usr/local/lib/edcb/BonDriver_mirakc.so.ini

# 4. B25Decoderのビルド
RUN git clone https://github.com/tsukumijima/Multi2Dec.git \
    && cd Multi2Dec/B25Decoder \
    && make USE_SIMD=y \
    && cp B25Decoder.so /usr/local/lib/edcb/

# 5. EpgTimerSrv.iniの初期設定
RUN tee /var/local/edcb/EpgTimerSrv.ini << 'EOT'
[SET]
EnableHttpSrv=1
HttpAccessControlList=+0.0.0.0/0,+::/0
RecEndMode=0
Data=1
EnableTCPSrv=1
[BonDriver_mirakc.so]
Count=8
GetEpg=1
EPGCount=8
Priority=0
EOT

RUN ln -sfv "../EpgTimerSrv.ini" "/var/local/edcb/Setting/EpgTimerSrv.ini"
RUN ln -sfv "../../../usr/local/bin/EpgDataCap_Bon" "/var/local/edcb/EpgDataCap_Bon"
RUN ln -sfv "../../../usr/local/bin/EpgTimerSrv" "/var/local/edcb/EpgTimerSrv"
RUN mkdir -p /var/local/edcb/Setting/EpgData
RUN mkdir -p /var/local/edcb/Setting/LogoData
# 6. 成果物の集約 (CMDより前に実行)
RUN mkdir -p /tmp/build_root/usr/local/lib/edcb 
RUN mkdir -p /tmp/build_root/var/local/edcb 
RUN mkdir -p /tmp/build_root/usr/local/bin 
RUN mkdir -p /tmp/build_root/usr/local/lib/lua/5.2 
RUN cp -a /usr/local/lib/edcb/. /tmp/build_root/usr/local/lib/edcb/ 
RUN cp -a /var/local/edcb/. /tmp/build_root/var/local/edcb/ 
RUN cp -a /usr/local/bin/Epg* /tmp/build_root/usr/local/bin/
RUN cp -a /usr/local/lib/liblua5.2.so /tmp/build_root/usr/local/lib/liblua5.2.so
RUN cp -a /usr/local/lib/lua/5.2/libzlib52.so /tmp/build_root/usr/local/lib/lua/5.2/libzlib52.so    


# entrypoint スクリプトのコピーと権限付与
COPY --chmod=755 ./build/builder/edcb.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
