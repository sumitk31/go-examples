package main
import (
	"fmt"
	"log"
	"context"
	"google.golang.org/grpc"
	"../calcpb"
)

func main(){
	fmt.Println("Hello I am client")
	cc,err := grpc.Dial("localhost:50051",grpc.WithInsecure())
	if err != nil{
		log.Fatal("Could not connect")
	}
	defer cc.Close()

	c := calcpb.NewAddServiceClient(cc)
	fmt.Println("craeted client %f",c)
	req := &calcpb.AddRequest{
	       
			Num1: 10,
			Num2: 20,
	
	}
	res,err := c.Add(context.Background(),req)
	if err !=nil{
		log.Fatalf("Error %v",err )
	}
	log.Printf("Response %v",res.Result)
}