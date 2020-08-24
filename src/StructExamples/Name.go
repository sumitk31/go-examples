package main

import "fmt"

type Name struct {
	firstName string
	lastName  string
}

func main() {
	Sumit := Name{"Sumit", "Kala"}
	fmt.Println(Sumit)
	fmt.Println(Sumit.firstName + Sumit.lastName)
	//Modify first name
	Sumit.firstName = "Sumit1"
	fmt.Println(Sumit.firstName + Sumit.lastName)
	//Print field names + values
	fmt.Printf("%+v", Sumit)
}
