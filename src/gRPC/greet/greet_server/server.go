package main

import (
	"fmt"
	"context"
	"log"
	"net"
	"google.golang.org/grpc"
	"../greetpb"
	)

type server struct{}

func (*server)Greet(ctx context.Context,req *greetpb.GreetRequest)(*greetpb.GreetResponse,error){
	fmt.Printf("Greet function was invoked with %v",req)
	firstName := req.GetGreeting().GetFname()
	result := "Hello " + firstName
	res := &greetpb.GreetResponse{
		Result: result,
	}
	return res,nil
}

func main(){
	fmt.Println("Hello world")
	lis,err := net.Listen("tcp","0.0.0.0:50051")
	if err!=nil{
		log.Fatal("Failed to Liste %v",err)

	}
	s:= grpc.NewServer()
	greetpb.RegisterGreetServiceServer(s,&server{})
	err = s.Serve(lis);
	if err!=nil{
		log.Fatal("failed to serve")
	}else{
		fmt.Println("Client connected")
	}
}