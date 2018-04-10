namerd:
	curl -v -XPUT -d @config/namerd.egress.dtab -H "Content-Type: application/dtab" http://127.0.0.1:4180/api/1/dtabs/consul_egress
	curl -v -XPUT -d @config/namerd.ingress.dtab -H "Content-Type: application/dtab" http://127.0.0.1:4180/api/1/dtabs/consul_ingress

test:
	curl -H "Host: echo" http://127.0.0.1:4140

restart:
	docker-compose restart

up:
	docker-compose up -d

down:
	docker-compose down

ps:
	docker ps -a

scale:
	docker-compose up -d --scale echo=5

simulate:
	wrk -c5 -d120 -t1 -H "Host: blue" http://127.0.0.1:4140

test-blue:
	curl -H "Host: blue" http://127.0.0.1:4140

test-green:
	curl -H "Host: green" http://127.0.0.1:4140

tenth:
	@curl -v -XPUT -d @config/namerd.tenth.dtab -H "Content-Type: application/dtab" http://127.0.0.1:4180/api/1/dtabs/consul_egress
	@curl http://127.0.0.1:4180/api/1/dtabs/consul_egress

half:
	@curl -v -XPUT -d @config/namerd.half.dtab -H "Content-Type: application/dtab" http://127.0.0.1:4180/api/1/dtabs/consul_egress
	@curl http://127.0.0.1:4180/api/1/dtabs/consul_egress

full:
	@curl -v -XPUT -d @config/namerd.full.dtab -H "Content-Type: application/dtab" http://127.0.0.1:4180/api/1/dtabs/consul_egress
	@curl http://127.0.0.1:4180/api/1/dtabs/consul_egress


proto:
	protoc --go_out=plugins=grpc:. route/route.proto

## GRPC

VERSION := $(shell git rev-parse HEAD)
BUILD_DATE := $(shell date -R)
VCS_URL := $(shell basename `git rev-parse --show-toplevel`)
VCS_REF := $(shell git log -1 --pretty=%h)
NAME := $(shell basename `git rev-parse --show-toplevel`)
VENDOR := $(shell whoami)

print:
	@echo VERSION=${VERSION} 
	@echo BUILD_DATE=${BUILD_DATE}
	@echo VCS_URL=${VCS_URL}
	@echo VCS_REF=${VCS_REF}
	@echo NAME=${NAME}
	@echo VENDOR=${VENDOR}

build-server:
	cd server && docker build -t alextanhongpin/grpc-server-noauth --build-arg VERSION="${VERSION}" \
	--build-arg BUILD_DATE="${BUILD_DATE}" \
	--build-arg VCS_URL="${VCS_URL}" \
	--build-arg VCS_REF="${VCS_REF}" \
	--build-arg NAME="${NAME}" \
	--build-arg VENDOR="${VENDOR}" .

build-client:
	cd client && docker build -t alextanhongpin/grpc-client-noauth --build-arg VERSION="${VERSION}" \
	--build-arg BUILD_DATE="${BUILD_DATE}" \
	--build-arg VCS_URL="${VCS_URL}" \
	--build-arg VCS_REF="${VCS_REF}" \
	--build-arg NAME="${NAME}" \
	--build-arg VENDOR="${VENDOR}" .

build-server-local:
	cd server && GOOS=linux GOARCH=arm CGO_ENABLED=0 go build -o app main.go
	cd server && docker build -f Dockerfile.dev -t alextanhongpin/grpc-server-noauth . && rm app

build-client-local:
	cd client && GOOS=linux GOARCH=arm CGO_ENABLED=0 go build -o app main.go
	cd client && docker build -f Dockerfile.dev -t alextanhongpin/grpc-client-noauth . && rm app

# For testing the gRPC Server
run-server:
	docker run --rm -d -p 50051:50051 -e PORT=0.0.0.0:50051 alextanhongpin/grpc-server-noauth

# For testing the gRPC
run-client:
	@docker run --rm -e PORT=docker.for.mac.localhost:4142 alextanhongpin/grpc-client-noauth
	# docker run --rm -e PORT=docker.for.mac.localhost:50051 alextanhongpin/grpc-client-noauth

h2:
	curl -svH "Host: proto.RouteGuide" -o/dev/null --http2 localhost:1234

describe-namerd:
	docker logs $(shell docker ps --filter name=namerd -q)

describe-linkerd:
	docker logs $(shell docker ps -a --filter name=linkerd -q)

describe-server:
	docker logs $(shell docker ps --filter name=grpcserver -q)

describe-client:
	docker logs $(shell docker ps -a --filter name=grpcclient -q)

describe-nginx:
	docker logs $(shell docker ps -a --filter name=nginx -q)


restart-linkerd:
	docker-compose restart linkerd

cert-linkerd:
	openssl req -nodes -x509 -newkey rsa:2048 -keyout cert/linkerd_key.pem -out cert/linkerd_cert.pem -days 365 -subj '/CN=linkerd'

cert-nginx:
	openssl req -nodes -x509 -newkey rsa:2048 -keyout cert/nginx_key.pem -out cert/nginx_cert.pem -days 365 -subj '/CN=nginx'

certstrap:
	certstrap init --common-name "CertAuth"
	certstrap request-cert --common-name linkerd
	certstrap sign linkerd --CA CertAuth


# SERVICE_NAME := linkerd

# certold:
# 	mkdir -p cert/{newcerts,private}
# 	echo 00 > cert/serial
# 	touch cert/index.txt
# 	openssl req -x509 -nodes -config openssl.cnf -newkey rsa:2048 \
#   -subj '/C=US/CN=My CA' -keyout cert/private/cakey.pem \
#   -out cert/cacert.pem

# 	# generate a certificate signing request with the common name "$SERVICE_NAME"
# 	openssl req -new -nodes -config openssl.cnf -subj "/C=US/CN=${SERVICE_NAME}" \
#   -keyout cert/private/${SERVICE_NAME}_key.pem \
#   -out cert/${SERVICE_NAME}_req.pem
 
# 	# have the CA sign the certificate
# 	openssl ca -batch -config openssl.cnf -keyfile cert/private/cakey.pem \
#   -cert cert/cacert.pem \
#   -out cert/${SERVICE_NAME}_cert.pem \
#   -infiles cert/${SERVICE_NAME}_req.pem