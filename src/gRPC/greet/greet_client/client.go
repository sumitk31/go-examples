package main
import (
	"fmt"
	"log"
	"context"
	"google.golang.org/grpc"
	"../greetpb"
)

func main(){
	fmt.Println("Hello I am client")
	cc,err := grpc.Dial("localhost:50051",grpc.WithInsecure())
	if err != nil{
		log.Fatal("Could not connect")
	}
	defer cc.Close()

	c := greetpb.NewGreetServiceClient(cc)
	fmt.Println("craeted client %f",c)
	req := &greetpb.GreetRequest{
		Greeting: &greetpb.Greeting{
			Fname: "Sumit",
			Lname: "Kala",
		},
	}
	res,err := c.Greet(context.Background(),req)
	if err !=nil{
		log.Fatalf("Error %v",err )
	}
	log.Printf("Response %v",res.Result)
}