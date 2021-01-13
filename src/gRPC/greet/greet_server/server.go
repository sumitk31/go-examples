package main

import (
	"fmt"
	"log"
	"net"
	"google.golang.org/grpc"
	"gRPC/greet/greetpb"
	)
	
type server struct{}

func main()
{
	fmt.Println("Hello world")
	lis,err := net.Listen("tcp","0.0.0.0:50051")
	if err!=nil{
		log.Fatal("Failed to Liste %v",err)

	}
	s:= grpc.NewServer()
	greetpb.RegisterGreetServiceServer(s,&server{})
	err:=s.Serve(lis);
	if err!=nil{
		log.Fatal("failed to serve")
	}
}