package main

import "fmt"

func main() {
	c := make(chan string)
	c <- "Hi there!"
	fmt.Println(<-c)
}
