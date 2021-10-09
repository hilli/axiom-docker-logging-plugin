FROM --platform=$BUILDPLATFORM golang:1.17.1 as builder
ARG TARGETARCH
ENV GO111MODULE=on GOOS=$TARGETOS GOARCH=$TARGETARCH

WORKDIR /go/src/github.com/axiomhq/axiom-logging-plugin/

COPY . /go/src/github.com/axiomhq/axiom-logging-plugin/

# RUN curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh

RUN cd /go/src/github.com/axiomhq/axiom-logging-plugin && go mod download

RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o /bin/axiom-logging-plugin .

FROM alpine:3.13
LABEL org.opencontainers.image.source http://github.com/axiomhq/docker-logging-plugin
RUN apk --no-cache add ca-certificates
COPY --from=builder /bin/axiom-logging-plugin /bin/
WORKDIR /bin/
ENTRYPOINT ["/bin/axiom-logging-plugin"]