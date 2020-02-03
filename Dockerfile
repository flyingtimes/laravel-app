FROM bitnami/laravel
LABEL maintainer "clarkchan <5200374@qq.com>"

EXPOSE 3000
COPY app-entrypoint.sh /
ENTRYPOINT [ "/app-entrypoint.sh" ]
CMD [ "php", "artisan", "serve", "--host=0.0.0.0", "--port=3000" ]
