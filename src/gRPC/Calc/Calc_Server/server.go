package main

import (
	"fmt"
	"context"
	"log"
	"net"
	"google.golang.org/grpc"
	"../calcpb"
	)

type server struct{}

func (*server)Add(ctx context.Context,req *calcpb.AddRequest)(*calcpb.AddResponse,error){
	fmt.Printf("Add function was invoked with %v",req)
	num1 :=  req.GetNum1()
	num2 := req.GetNum2()
	result := num1+num2
	res := &calcpb.AddResponse{
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
	calcpb.RegisterAddServiceServer(s,&server{})
	
	err = s.Serve(lis);
	if err!=nil{
		log.Fatal("failed to serve")
	}else{
		fmt.Println("Client connected")
	}
}