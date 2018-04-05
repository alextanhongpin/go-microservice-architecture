namerd:
	curl -v -XPUT -d @config/namerd.egress.dtab -H "Content-Type: application/dtab" http://localhost:4180/api/1/dtabs/consul_egress
	curl -v -XPUT -d @config/namerd.ingress.dtab -H "Content-Type: application/dtab" http://localhost:4180/api/1/dtabs/consul_ingress

test:
	curl -H "Host: echo" http://127.0.0.1:4140/

restart:
	docker-compose restart

up:
	docker-compose up -d

down:
	docker-compose down