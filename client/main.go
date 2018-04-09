package main

import (
	"context"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"strings"
	"time"

	pb "github.com/alextanhongpin/go-microservice-architecture/route"
	"google.golang.org/grpc"
	"google.golang.org/grpc/metadata"
)

type grpcClient struct {
	client pb.RouteGuideClient
}

func (grpc grpcClient) GetFeature() {
	feature, err := grpc.client.GetFeature(context.Background(), &pb.Point{409146138, -746188906})
	if err != nil {
		log.Printf("Error getting feature: %v\n", err)
	}
	log.Printf("Got feature: %v\n", feature)
}

func (grpc grpcClient) ListFeatures() {

	rect := &pb.Rectangle{
		Lo: &pb.Point{
			Latitude:  10000,
			Longitude: 10000,
		},
		Hi: &pb.Point{
			Latitude:  10000,
			Longitude: 10000,
		},
	}
	stream, err := grpc.client.ListFeatures(context.Background(), rect)
	if err != nil {
		log.Fatal(err)
	}
	for {
		feature, err := stream.Recv()
		if err == io.EOF {
			break
		}
		if err != nil {
			log.Fatalf("%v.ListFeatures(_) = _, %v", grpc.client, err)
		}
		log.Println(feature)
	}
}

func (grpc grpcClient) RecordRoute() {
	var points []*pb.Point
	for i := 0; i < 10; i++ {
		points = append(points, &pb.Point{
			Latitude:  int32(time.Now().Unix()),
			Longitude: int32(time.Now().Unix()),
		})
	}
	stream, err := grpc.client.RecordRoute(context.Background())
	if err != nil {
		log.Fatal(err)
	}
	for _, point := range points {
		if err := stream.Send(point); err != nil {
			log.Fatal(err)
		}
	}
	reply, err := stream.CloseAndRecv()
	if err != nil {
		log.Fatal(err)
	}
	log.Printf("Got reply: %v", reply)
}

func (grpc grpcClient) RouteChat(ctx context.Context) {
	notes := []*pb.RouteNote{
		&pb.RouteNote{
			Location: &pb.Point{
				Latitude:  1000,
				Longitude: 1000,
			},
			Message: "hello world",
		},
		&pb.RouteNote{
			Location: &pb.Point{
				Latitude:  1000,
				Longitude: 1000,
			},
			Message: "hello world 2",
		},
	}
	stream, err := grpc.client.RouteChat(ctx)
	if err != nil {
		log.Fatal(err)
	}
	waitc := make(chan struct{})
	go func() {
		for {
			in, err := stream.Recv()
			if err == io.EOF {
				close(waitc)
				log.Fatal(err)
				return
			}
			if err != nil {
				log.Fatalf("Failed to receive note:%v", err)
				return
			}
			log.Printf("Got message %v", in)
		}
	}()

	for _, note := range notes {
		if err := stream.Send(note); err != nil {
			log.Fatal(err)
		}
	}
	stream.CloseSend()
	<-waitc
}

func main() {
	svcURL := os.Getenv("SVC_URL")
	port := os.Getenv("PORT")
	if port == "" {
		port = ":1234"
	}

	if svcURL == "" {
		svcURL = ":50051"
	}
	conn, err := grpc.Dial(svcURL, grpc.WithInsecure())
	if err != nil {
		log.Fatal(err)
	}
	defer conn.Close()

	// client := pb.NewRouteGuideClient(conn)

	client := grpcClient{
		client: pb.NewRouteGuideClient(conn),
	}

	// client.GetFeature()
	// client.ListFeatures()
	// client.RecordRoute()

	mux := http.NewServeMux()
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		ctx := getContext(r)
		log.Printf("%+v\n", r.Header)
		client.RouteChat(ctx)
		fmt.Fprintf(w, `{"output": "%v"}`, "ok")
	})

	log.Printf("listening to port *%s. press ctrl + c to cancel.\n", port)
	log.Fatal(http.ListenAndServe(port, mux))
}

func getContext(req *http.Request) context.Context {
	headers := make(map[string]string)
	for k, values := range req.Header {
		prefixed := func(s string) bool { return strings.HasPrefix(k, s) }
		if prefixed("L5d-") || prefixed("Dtab-") || prefixed("X-Dtab-") {
			if len(values) > 0 {
				headers[k] = values[0]
			}
		}
	}
	log.Println("headers", headers)
	md := metadata.New(headers)
	ctx := metadata.NewIncomingContext(context.Background(), md)
	return ctx
}
