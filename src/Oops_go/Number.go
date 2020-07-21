package main

import "fmt"

type number []int

func (n number) PrintDouble() {
	for i, num := range n {
		fmt.Println(i, 2*num)

	}

}
