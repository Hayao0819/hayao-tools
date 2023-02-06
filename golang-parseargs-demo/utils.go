package main
import "strings"


func containsStr(array []string, target string) bool {
    for _, item := range array {
        if item == target {
            return true
        }
    }
    return false
}

func isReqArg(arg string)(bool){
	return strings.HasSuffix(arg, ":")
}

func isLongOpt(arg string)(bool){
	return strings.HasPrefix(arg, "--")
}

func removeHyphenFromLongOpt(arg string)(string){
	return strings.TrimPrefix(arg, "--")
}
