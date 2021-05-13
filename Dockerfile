FROM golang:alpine

RUN mkdir /proto

RUN mkdir /stubs

RUN apk -U --no-cache add git protobuf

RUN go get -u -v github.com/golang/protobuf/protoc-gen-go \
	google.golang.org/grpc \
	google.golang.org/grpc/reflection \
	golang.org/x/net/context \
	github.com/go-chi/chi \
	github.com/lithammer/fuzzysearch/fuzzy \
	golang.org/x/tools/imports

RUN go get github.com/markbates/pkger/cmd/pkger

# cloning well-known-types
RUN git clone https://github.com/google/protobuf.git /protobuf-repo
RUN git clone https://github.com/googleapis/googleapis.git /googleapis
RUN git clone https://github.com/envoyproxy/protoc-gen-validate /protoc-gen-validate
RUN git clone https://github.com/grpc-ecosystem/grpc-gateway /grpc-gateway

RUN mkdir protobuf

# only use needed files
RUN mv /protobuf-repo/src/ /protobuf/
RUN cp -rf /googleapis/google/* /protobuf/google/
RUN mv /protoc-gen-validate/validate /protobuf/
RUN mv /grpc-gateway/protoc-gen-openapiv2 /protobuf/

RUN rm -rf /protobuf-repo
RUN rm -rf /googleapis
RUN rm -rf /protoc-gen-validate
RUN rm -rf /grpc-gateway

RUN mkdir -p /go/src/github.com/tokopedia/gripmock

COPY . /go/src/github.com/tokopedia/gripmock

WORKDIR /go/src/github.com/tokopedia/gripmock/protoc-gen-gripmock

RUN pkger

# install generator plugin
RUN go install -v

WORKDIR /go/src/github.com/tokopedia/gripmock

# install gripmock
RUN go install -v

RUN go get github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2/options
RUN go get github.com/grpc-ecosystem/grpc-gateway
RUN go mod download github.com/envoyproxy/protoc-gen-validate
RUN go mod download golang.org/x/net
RUN go mod download google.golang.org/genproto
RUN go mod download google.golang.org/grpc
RUN go mod download golang.org/x/sys
RUN go mod download golang.org/x/text
EXPOSE 4770 4771

ENTRYPOINT ["gripmock"]
