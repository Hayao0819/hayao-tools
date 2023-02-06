package main

import (
	"fmt"
	"os"
	"strings"
)

type nullStr struct{
	String string
	Vaild bool
}

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

// 全オプション一覧から引数を受け取るものと受け取らないもので分ける
// 返り値はwithArg, withoutArg
func categorizeOpt(opts []string)([]string, []string){
	var withArg []string
	var withoutArg []string

	for _, opt := range opts{
		if isReqArg(opt){
			//withArg=append(withArg, opt)
			withArg = append(withArg, strings.TrimSuffix(opt, ":"))
		}else{
			withoutArg = append(withoutArg, opt)
		}
	}

	return withArg,withoutArg
}

func formatArgs(long, short, args []string)([]string, error){
	var result []string
	var longWithoutArg []string
	var longWithArg []string
	var shortWithArg []string
	var shortWithoutArg []string
	var arg , orgArg string
	var next_arg nullStr
	
	// Parse long
	longWithArg, longWithoutArg = categorizeOpt(long)
	shortWithArg, shortWithoutArg = categorizeOpt(short)
	long = append(longWithArg, longWithoutArg...)
	short = append(shortWithArg, shortWithoutArg...)


	//for _, arg := range args{
	for index := 0; index<len(args); index++{
		arg = args[index]
		if index+1 != len(args){
			next_arg.String = args[index+1]
			next_arg.Vaild = true
		}else{
			next_arg.String = ""
			next_arg.Vaild = false
		}

		if isLongOpt(arg){
			// ロングオプション
			orgArg = arg
			arg = removeHyphenFromLongOpt(arg)

			if containsStr(long, arg){
				result = append(result, orgArg)
				if containsStr(longWithArg, arg){
					// 引数を取る場合
					if next_arg.Vaild == true{
						result = append(result, args[index+1])
						index++
					}else{
						return nil, &ErrNoArg{Arg: arg}
					}
				}
			}
		}
	}

	return result, nil
}
