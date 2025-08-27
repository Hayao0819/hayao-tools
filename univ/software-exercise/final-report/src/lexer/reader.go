package lexer

// 全てのトークンを読んで返す
func (l *Lexer) ReadAll() ([]Token, error) {
	var tokens []Token
	for {
		token, err := l.NextToken()
		if err != nil {
			return nil, err
		}

		tokens = append(tokens, *token)
		if token.Type == TokenEOT {
			break
		}
	}
	return tokens, nil
}
