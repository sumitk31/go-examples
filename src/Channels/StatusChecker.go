package main

import (
	"fmt"
	"net/http"
)

func main() {

	links := []string{
		"http://google.com",
		"http://yahoo.com",
	}
	c := make(chan string) // make a channel to wait for child routines

	for _, link := range links {
		fmt.Println("checking ", link)
		go checkLink(link, c)
	}
	for {
		go checkLink(<-c, c)
	}

}

func checkLink(link string, c chan string) {
	_, err := http.Get(link)
	if err != nil {
		fmt.Println(link, " is down")

	} else {
		fmt.Println(link, " is up")
	}
	c <- link
	return
}
