package parser

// BNFベースのSimpleCommand構築に書き換え
// func (p *Parser) parseCommandCall(cur *cursor) (*ast.SimpleCommand, error) {
// 	elements := []ast.Node{}
// 	for cur.hasNext() {
// 		tok := cur.peek()
// 		switch tok.Type {
// 		case lexer.TokenWhitespace, lexer.TokenQuoteChar:
// 			cur.next() // skip
// 		case lexer.TokenRedirection:
// 			logmgr.Parser().Debug("ParserFoundRedirection", "op", tok.Text)
// 			redir, err := p.parseRedirection(cur)
// 			if err != nil {
// 				return nil, err
// 			}
// 			elements = append(elements, redir)
// 		case lexer.TokenEscapeChar, lexer.TokenString, lexer.TokenQuotedString:
// 			elements = append(elements, &ast.Word{Value: cur.next().String()})
// 		case lexer.TokenPipe:
// 			// パイプはここでは処理しない（パイプライン構築はparser.goで行う）
// 			return &ast.SimpleCommand{Elements: elements}, nil
// 		default:
// 			cur.next() // skip unexpected tokens
// 		}
// 	}
// 	return &ast.SimpleCommand{Elements: elements}, nil
// }

// parseRedirection parses a redirection (>, >>, <, etc.) and its target
// func (p *Parser) parseRedirection(cur *cursor) (*ast.Redirection, error) {
// 	op := cur.next().Text // consume redirection operator (e.g., >, <)

// 	// Skip whitespace and quote characters
// 	for cur.hasNext() {
// 		switch cur.peek().Type {
// 		case lexer.TokenWhitespace, lexer.TokenQuoteChar:
// 			cur.next()
// 		default:
// 			goto FindFile
// 		}
// 	}

// FindFile:
// 	// ファイル名・またはファイルディスクリプタを取得する
// 	file := ""

// 	if !cur.hasNext() {
// 		return nil, fmt.Errorf("syntax error: expected filename after '%s'", op)
// 	}

// ReadFileLoop:
// 	for cur.hasNext() {
// 		tok := cur.peek()

// 		switch tok.Type {
// 		case lexer.TokenEscapeChar, lexer.TokenString, lexer.TokenQuotedString:
// 			file += cur.next().String()
// 		case lexer.TokenAnd:
// 			cur.next() // consume '&'
// 			if cur.hasNext() && cur.peek().Type == lexer.TokenNumber {
// 				numTok := cur.next()
// 				// 数値じゃなかったらエラー扱い
// 				if _, err := strconv.Atoi(numTok.Text); err != nil {
// 					return nil, fmt.Errorf("syntax error: invalid file descriptor after '>&'")
// 				}
// 				logmgr.Parser().Warn("Redirecting to FD is not supported yet", "op", op, "fd", numTok.Text)
// 			} else {
// 				return nil, fmt.Errorf("syntax error: expected file descriptor after '>&'")
// 			}
// 		case lexer.TokenRedirection:
// 			// 連続リダイレクト禁止
// 			return nil, fmt.Errorf("syntax error: unexpected '%s' after redirection '%s'", tok.Text, op)
// 		default:
// 			break ReadFileLoop
// 		}
// 	}

// 	if strings.TrimSpace(file) == "" {
// 		return nil, fmt.Errorf("syntax error: missing filename after '%s'", op)
// 	}

// 	return &ast.Redirection{
// 		Operator: op,
// 		Target:   &ast.Word{Value: file},
// 	}, nil
// }
