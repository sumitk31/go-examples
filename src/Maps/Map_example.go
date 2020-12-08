package main

import (
	"fmt"
)

func main() {
	//var colors map[string]string
	colors := make(map[string]string)
	//Add some entries
	colors["Red"] = "#00001"
	colors["Green"] = "#00002"
	colors["Blue"] = "#00003"
	fmt.Println(colors)
	//Delete Blue
	delete(colors, "Blue")
	fmt.Println(colors)
	fmt.Println("Printing the Map")
	printMap(colors)
	modifyMap(&colors)
	fmt.Println("\nprinting Modified Map")
	printMap(colors)

}

func printMap(c map[string]string) {
	for color, code := range c {
		fmt.Println("\ncode for ", color, "is", code)
	}
}

func modifyMap(c *map[string]string) {
	for color := range *c {
		(*c)[color] = (*c)[color] + "Hello"
	}
}
