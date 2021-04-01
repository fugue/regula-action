FROM fugue/regula:v0.7.0
RUN apk add --update jq
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
