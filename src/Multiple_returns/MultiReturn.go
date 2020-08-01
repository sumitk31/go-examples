package main

import "fmt"

//Function returning an integer and a String
func getIntString() (int, string) {
	return 5, "Hello"
}
func main() {
	myint, mystring := getIntString()
	fmt.Println(myint, mystring)
}
