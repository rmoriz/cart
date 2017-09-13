FROM golang:alpine

RUN apk add --no-cache git tar curl \
     && go get -u -d github.com/mholt/caddy/caddy \
     && go get -u -d github.com/epicagency/caddy-expires \
     && go get -u -d github.com/caddyserver/builds \
     && go get -u -d github.com/nicolasazrak/caddy-cache \ 
     && go get -u -d github.com/captncraig/cors

WORKDIR /go/src/github.com/mholt/caddy
ADD patches/cleanup.patch cleanup.patch
RUN patch -p1 < cleanup.patch 

WORKDIR /go/src/github.com/mholt/caddy/caddy/caddymain

RUN sed -i '/\/\/ This is where other plugins get plugged in (imported)/a  _ "github.com/nicolasazrak/caddy-cache"\n' run.go \
    && sed -i '/\/\/ This is where other plugins get plugged in (imported)/a  _ "github.com/captncraig/cors"\n' run.go \
    && sed -i '/\/\/ This is where other plugins get plugged in (imported)/a  _ "github.com/epicagency/caddy-expires"\n' run.go

WORKDIR /go/src/github.com/mholt/caddy/caddy
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o caddy  && ./caddy -version
# /go/src/github.com/mholt/caddy/caddy/caddy

