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
