/**
 * File: main.go
 * Written by: Stephen M. Reaves
 * Created on: Wed, 09 Oct 2019
 */

package main

import (
  "fmt"
  "os"
  "strings"
  "bufio"
  "regexp"
)

var prompt string;

func prepareArg(match [][]string) {
  arg   := match[0][1]
  value := match[1][2]

  switch arg {
    case `prompt`, `PS1`:
      prompt = value
  }
}

func execInput(input string) {
  // Remove new line
  input = strings.TrimSuffix(input, '\n')
}

func main() {
  // Defaults
  prompt = "> "
  match := regexp.MustCompile(`^--([[:alnum:]]+)=|(.*)$`)
  reader := bufio.NewReader(os.Stdin)

  // Handle commandline arguments
  for i, arg := range os.Args {
    // Arg[0] is name of function
    if i > 0 {
      argMatch := match.FindAllStringSubmatch(arg, -1)
      prepareArg(argMatch)
    }
  }

  // Shell
  for/*ever*/ {
    // Read input
    input, err := reader.ReadString('\n')
    if err != nil {
      fmt.Fprintln(os.Stderr, err)
    }

    // Prompt
    fmt.Print(prompt)

    execInput(input)
    os.Exit(0)
  }
}
