FROM golang:alpine AS builder
RUN adduser -D -g '' appuser
ARG appfolder="app"
RUN apk update && apk add --no-cache git ca-certificates tzdata && update-ca-certificates
WORKDIR /go/src/phoenix/go-calc-backend
COPY ${appfolder}/ .
RUN go get -d -v
RUN GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -o /go/bin/go-calc-backend 

FROM alpine:latest as go-calc-backend
COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /go/bin/go-calc-backend /go/bin/go-calc-backend 
EXPOSE 8080
USER appuser
ENTRYPOINT ["/go/bin/go-calc-backend"]