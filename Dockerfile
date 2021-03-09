FROM fugue/regula:latest
RUN apk add --update jq
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
