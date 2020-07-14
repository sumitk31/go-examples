package main

import "fmt"

func return_string() string {
	return "Returning this"
}

func main() {

	fmt.Println(return_string())
	newString := return_string()
	fmt.Println(newString)
}
