package main

import "fmt"

func main() {
	int_slice := []int{0, 1, 2, 3, 4, 5, 6, 7, 8, 10}
	for _, entry := range int_slice {
		if entry%2 == 0 {
			fmt.Println("Even")
		} else {
			fmt.Println("odd")
		}
	}
}
