package main

import "fmt"

type ContactInfo struct {
	email   string
	zipcode int
}
type Record struct {
	firstName string
	lastName  string
	contact   ContactInfo
}

// Receiver which receives MyName object
func (p Record) printInfo() {
	fmt.Println(p)
}

func (p Record) updateName(newname string) { // pass by value
	p.firstName = newname
}
func (PointerToRecord *Record) updateNameRef(newname string) { // pass by reference
	(*PointerToRecord).firstName = newname
}

func main() {
	record := Record{}
	record.firstName = "Sumit"
	record.lastName = "Kala"
	record.contact.email = "sumitk31@gmail.com"
	record.contact.zipcode = 560035
	recordPtr := &record

	recordPtr.updateNameRef("Rahul")
	record.printInfo()
	record.updateNameRef("Sumit") // shortcut
	record.printInfo()
}
