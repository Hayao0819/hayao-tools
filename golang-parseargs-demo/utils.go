package main
import "strings"

func rmTopChr(cnt int, text string)(string){ 
	return string([]rune(text)[cnt:])
}

func containsStr(array []string, target string) bool {
    for _, item := range array {
        if item == target {
            return true
        }
    }
    return false
}

func longReqArg(arg string)(bool){
	return strings.HasSuffix(arg, ":")
}

func isLongOpt(arg string)(bool){
	return strings.HasPrefix(arg, "--")
}
