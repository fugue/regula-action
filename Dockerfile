FROM fugue/regula:v0.7.0-rc.1
RUN apk add --update jq
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
