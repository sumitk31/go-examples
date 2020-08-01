package main

import "fmt"

// Go has only for loop
func main() {
	//define a slice
	number := []int{1, 2, 3, 4, 5, 6, 7, 8, 9}
	// For loop with range
	for i, num := range number {
		fmt.Println(i, num)
	}
	//For loop with init,condition and increment
	fmt.Println("Second Loop")
	for i := 1; i < 10; i++ {
		fmt.Println(i)
	}

	//add to slice
	number = append(number, 10, 11)
	// while loop wih help of for
	fmt.Println("Third Loop")
	i := 0
	for i < len(number) {
		fmt.Println(i, number[i])
		i++
	}
}
