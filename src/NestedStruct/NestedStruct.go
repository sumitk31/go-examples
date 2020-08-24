package main

import "fmt"

type ContactInfo struct {
	email   string
	zipcode int
}
type MyName struct {
	firstName string
	lastName  string
	contact   ContactInfo
}

func main() {
	record := MyName{}
	record.firstName = "Sumit"
	record.lastName = "Kala"
	record.contact.email = "sumitk31@gmail.com"
	record.contact.zipcode = 560035
	//Print field names + values
	fmt.Printf("%+v\n", record)
}
