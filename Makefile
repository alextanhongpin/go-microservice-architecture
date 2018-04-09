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