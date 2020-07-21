package main

import "fmt"

func main() {
	number := []int{1, 2, 3, 4, 5, 6, 7, 8, 9}
	for i, num := range number {
		fmt.Println(i, num)
	}
	fmt.Println("Second Loop")
	for i := 1; i < 10; i++ {
		fmt.Println(i)
	}
}
