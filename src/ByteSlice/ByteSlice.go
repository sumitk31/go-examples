package main

import (
	"fmt"
	"io/ioutil"
)

type numarr []int

func (n numarr) toString() string {
	var num_as_string string
	for i := 0; i < len(n); i++ {
		//add each number to the string
		num_as_string = num_as_string + string(n[i])
	}
	return num_as_string
}

// Go has only for loop
func main() {
	//define a slice
	number := numarr{1, 2, 3, 4, 5, 6, 7, 8, 9, 65, 66}
	fmt.Println(number.toString())
	//Convert the string to Byte Slice
	fmt.Println([]byte(number.toString()))
	//Write the byte slice to File
	ioutil.WriteFile("Myfle", []byte(number.toString()), 0666)
	// Read the bytes back from the file
	bs, err := ioutil.ReadFile("Myfle")
	fmt.Println(err)
	//print the bytes back
	fmt.Println(bs)
	//print the bytes as string
	fmt.Println(string(bs))
}
