ARG GO_VERSION=1.15
ARG TARGET=alpine:3.9
ARG VERSION

FROM golang:${GO_VERSION}-alpine AS builder

RUN apk add --no-cache ca-certificates git

WORKDIR /src
COPY ./go.mod ./go.sum ./
RUN go mod download

# Import the code from the context.
COPY ./ ./
RUN CGO_ENABLED=0 go build -installsuffix 'static' -ldflags "-X main.date=`date -u +%Y-%m-%dT%H:%M:%SZ` -X main.version=$VERSION" -o /app .

FROM ${TARGET} AS final

RUN apk update && apk add ca-certificates && rm -rf /var/cache/apk/*

WORKDIR /bin
COPY --from=builder /app ./htmltest
WORKDIR /test
ENTRYPOINT ["htmltest"]
CMD ["./"]
