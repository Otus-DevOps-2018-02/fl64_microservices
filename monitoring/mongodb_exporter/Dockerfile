FROM golang:latest as builder
LABEL maintainer="Tishkov Pavel <tishkov.pavel@gmail.com>"

ENV APP $GOPATH/src/github.com/percona/mongodb_exporter
WORKDIR $APP

RUN git clone -b v0.4.0 "https://github.com/percona/mongodb_exporter" "$APP" \
    && go get -d \
    && go build -o mongodb_exporter
#RUN pwd
#RUN ls

FROM golang:latest
COPY --from=builder /go/src/github.com/percona/mongodb_exporter/mongodb_exporter /bin/mongodb_exporter
EXPOSE 9216
ENTRYPOINT [ "/bin/mongodb_exporter" ]
