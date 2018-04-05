# Go Microservice Architecture

Sample architecture with Go, showing how the different pieces are tied together.

## Architecture

![architecture](assets/architecture.png)

TODO: Cleanup the diagram, and add more services

## Start

```bash
$ docker-compose up -d
```

## UI

- consul: [localhost:8500](http://localhost:8500)
- traefik: [localhost:8080](http://localhost:8080)
- jaeger: [localhost:16686](http://localhost:16686)
- prometheus: [localhost:9090](http://localhost:9090)
- grafana: [localhost:3000](http://localhost:3000)
- linkerd: [localhost:9990](http://localhost:9990)

## Call the Echo Service

Scale the service:

```bash
$ docker-compose up -d --scale node=10
```

```bash
$ repeat 10; curl -H "Host: echo.consul.localhost" localhost:80 && printf "\n";
```

Output:

```bash
{"hostname":"e7d4b1cc317c","text":"hello"}
{"hostname":"0bdb052e096a","text":"hello"}
{"hostname":"62fa842dcf9c","text":"hello"}
{"hostname":"2e7f8dcbbc43","text":"hello"}
{"hostname":"1a59218e8121","text":"hello"}
{"hostname":"bee0e7437024","text":"hello"}
{"hostname":"547af30289ee","text":"hello"}
{"hostname":"fec9b78a7e7c","text":"hello"}
{"hostname":"a27f75db0290","text":"hello"}
{"hostname":"5a9726496329","text":"hello"}
```

## Calling Linkerd

In `linkerd.yaml`, we set it to listen to consul for changes and register the services there. We expose the port `:4040` as the load balancer ingress, and set the identifier to `io.l5d.header.token`. To call the echo service:

```bash
$ curl -H "Host: echo" localhost:4140
```

## Setup Namerd

### Creating Egress

```bash
$ curl -v -XPUT -d @config/namerd.egress.dtab -H "Content-Type: application/dtab" http://localhost:4180/api/1/dtabs/consul_egress
```

Output:

```bash
*   Trying ::1...
* TCP_NODELAY set
* Connected to localhost (::1) port 4180 (#0)
> PUT /api/1/dtabs/consul_egress HTTP/1.1
> Host: localhost:4180
> User-Agent: curl/7.54.0
> Accept: */*
> Content-Type: application/dtab
> Content-Length: 34
>
* upload completely sent off: 34 out of 34 bytes
< HTTP/1.1 204 No Content
<
* Connection #0 to host localhost left intact
```


### Creating Ingress

```bash
$ curl -v -XPUT -d @config/namerd.ingress.dtab -H "Content-Type: application/dtab" http://localhost:4180/api/1/dtabs/consul_ingress
```

Output:

```bash
*   Trying ::1...
* TCP_NODELAY set
* Connected to localhost (::1) port 4180 (#0)
> PUT /api/1/dtabs/consul_ingress HTTP/1.1
> Host: localhost:4180
> User-Agent: curl/7.54.0
> Accept: */*
> Content-Type: application/dtab
> Content-Length: 35
>
* upload completely sent off: 35 out of 35 bytes
< HTTP/1.1 204 No Content
<
* Connection #0 to host localhost left intact
```

## Make Call

```bash
$ curl -H "Host: echo" localhost:4140
```

## TODO

- cleanup code
- create kubernetes example