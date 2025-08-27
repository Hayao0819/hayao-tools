package lexer

import "encoding/json"

func PrintJSON(ts []Token) {
	j, err := json.Marshal(ts)
	if err != nil {
		panic(err)
	}
	println(string(j))
}
