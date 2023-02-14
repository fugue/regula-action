FROM fugue/regula:v3.1.0 AS regula
USER root
RUN apk add --update bash jq
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
