FROM golang:1.8
#RUN git clone https://github.com/percona/mongodb_exporter.git && cd  mongodb_exporter && make init && make build
RUN go build -o mongodb_exporter github.com/percona/mongodb_exporter



#FROM        quay.io/prometheus/busybox:latest
#
#COPY mongodb_exporter /bin/mongodb_exporter
#
#EXPOSE      9216
#ENTRYPOINT  [ "/bin/mongodb_exporter" ]
