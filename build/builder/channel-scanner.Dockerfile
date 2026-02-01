# channel-scanner.Dockerfile の修正
FROM dtv-build-recisdb AS scanner-base

# すべてのバイナリを /usr/local/bin に集約
COPY --from=dtv-build-libarib25 /tmp/build_root/. /
COPY --from=dtv-build-isdbscanner /tmp/build_root/. /
COPY --from=dtv-build-edcb /tmp/build_root/. /
COPY --from=dtv-build-mirakurun /tmp/build_root/. /
# recisdb はベースイメージですでに /usr/local/bin/recisdb にあるはず

# 依存ライブラリの更新
RUN ldconfig

# entrypoint スクリプトのコピーと権限付与
COPY --chmod=755 ./build/builder/channel-scanner.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]