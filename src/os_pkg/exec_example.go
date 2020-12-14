package main

import "fmt"
import "os/exec"

func main() {
	cmd := exec.Command("ls", "-l")
	output, err := cmd.CombinedOutput()
	fmt.Println(string(output), err)
}
