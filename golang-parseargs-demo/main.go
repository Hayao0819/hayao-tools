package main

import (
	"fmt"
	"os"
)

func main(){
	args := os.Args
	longOpts := []string{"help", "test:"}
	shortOpts := []string{"h", "t:"}
	formated, err := formatArgs(longOpts, shortOpts, args)

	if err != nil{
		fmt.Println(err)
		os.Exit(1)
	}else{
		fmt.Println(formated)
		os.Exit(0)
	}
}


func formatArgs(long, short, args []string)([]string, error){
	var result []string
	var longWithoutArg []string
	var longWithArg []string
	var shortWithArg []string
	var shortWithoutArg []string
	var arg string
	
	// Parse long
	


	//for _, arg := range args{
	for index := 0; index<len(args); index++{
		arg = args[index]

		if isLongOpt(arg){
			// ロングオプション
			if containsStr(long, rmTopChr(2, arg)){
				result = append(result, arg)
				if longReqArg(arg){
					result = append(result, args[index+1])
					index++
				}
			}
		}
	}

	return result, nil
}
