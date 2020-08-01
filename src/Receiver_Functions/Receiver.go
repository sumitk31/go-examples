package main

import "fmt"

// Custom type declaration numbers is a slice of integers
type numbers []int

//Define a receiver function
// The below function receives a slice of numbers and
// returns another slice with all the numbers doubled.
//In the below example myprint is a function accessible to all variables of type numbers.
func (mynums numbers) myprint() numbers {
	double_nums := numbers{}
	for i, num := range mynums {
		fmt.Println(i, num)
		double_nums = append(double_nums, num*2)
	}
	return double_nums
}

func main() {
	fmt.Println("Running program")
	nums := numbers{1, 2, 3, 4, 5}
	double_numbs := nums.myprint()
	fmt.Println(" Printing the Double Slice")
	//for i, num := range double_numbs {// This will give a compilation error since i is not used to avoid the error
	// we can use _
	for _, num := range double_numbs { // _ is used to ignore the index returned from range
		fmt.Println(num)
	}

}
