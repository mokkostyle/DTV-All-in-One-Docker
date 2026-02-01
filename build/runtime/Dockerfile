FROM dtv-build-runtime
# COPY ./dist/usr/local/lib/. /usr/local/lib/
# COPY ./dist/usr/local/bin/. /usr/local/bin/
# COPY ./dist/usr/local/etc/. /usr/local/etc/
# COPY ./dist/usr/local/include/. /usr/local/include/
# 権限付与
COPY --chmod=755 ./build/runtime/entrypoint.sh /usr/local/bin/entrypoint.sh

# ポート公開（EXPOSEはドキュメントとしての意味が強いのでまとめて記述）
EXPOSE 40772 8000 4510 5510 7000 7010

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]