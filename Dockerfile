FROM  golang:1.17.1

WORKDIR /go/src/github.com/axiomhq/axiom-logging-plugin/

COPY . /go/src/github.com/axiomhq/axiom-logging-plugin/

# RUN curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh

RUN cd /go/src/github.com/axiomhq/axiom-logging-plugin && go mod download

RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o /bin/axiom-logging-plugin .

FROM alpine:3.7
RUN apk --no-cache add ca-certificates
COPY --from=0 /bin/axiom-logging-plugin /bin/
WORKDIR /bin/
ENTRYPOINT ["/bin/axiom-logging-plugin"]