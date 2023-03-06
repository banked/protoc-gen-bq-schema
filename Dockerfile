# syntax=docker/dockerfile:1

# Stage 1 - Build Statically Linked Binary
FROM golang:bullseye AS build

COPY . .

ENV GOOS=linux 
ENV COARCH=amd64 
ENV CGO_ENABLED=0
ENV GOPATH=

RUN go build \
  -ldflags="-extldflags=-static -w -s" \
  -trimpath \
  -o /protoc-gen-bq-schema \
  ./main.go

RUN mv /go/bin/linux_amd64/* /go/bin || true

# Stage 2 - Copy binary
FROM scratch

COPY --from=build --link /etc/passwd /etc/passwd
COPY --from=build /protoc-gen-bq-schema /

USER nobody

CMD ["/protoc-gen-bq-schema"]
