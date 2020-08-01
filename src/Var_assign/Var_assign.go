package main

import "fmt"

func main() {
	var deckSize = 52
	var card = "Ace of spades"
	card2 := "Hello World" // Same as line 7 above
	fmt.Println(card)
	fmt.Println(card2)
	//card = 52   not allowed as Go is Statically typed language.
	fmt.Println(card)
	fmt.Println(deckSize)
}
