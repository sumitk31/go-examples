package main

import "fmt"

type triangle struct {
	height float64
	base   float64
}
type square struct {
	side float64
}

func (t triangle) getArea() float64 {
	return (t.base * t.height) / 2
}

func (s square) getArea() float64 {
	return s.side * s.side
}

type shape interface {
	getArea() float64
}

func main() {

	var t1 triangle
	var s1 square
	t1.height = 8
	t1.base = 7
	s1.side = 8
	fmt.Println(t1.getArea())
	fmt.Println(s1.getArea())

}
