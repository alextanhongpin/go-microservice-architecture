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

- consul: localhost:8500
- traefik: localhost:8080
- jaeger: localhost:16686
- prometheus: localhost:9090
- grafana: localhost:3000

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