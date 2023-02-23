FROM fugue/regula:v3.2.1 AS regula
USER root
RUN apk add --update bash jq
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
