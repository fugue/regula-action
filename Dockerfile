FROM fugue/regula:v2.8.1 AS regula
USER root
RUN apk add --update bash jq
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
