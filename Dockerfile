FROM fugue/regula:v2.0.0 AS regula
USER root
RUN apk add --update bash jq
USER ${APP_USER}
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
