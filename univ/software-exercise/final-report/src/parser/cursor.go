package parser

// type cursor struct {
// 	processed int
// 	tokens    []lexer.Token
// }

// func (c *cursor) next() lexer.Token {
// 	if c.processed >= len(c.tokens) {
// 		return lexer.Token{}
// 	}
// 	logmgr.Parser().Info("ParserNextToken", "token", c.tokens[c.processed])
// 	token := c.tokens[c.processed]
// 	c.processed++
// 	return token
// }

// func (c *cursor) left() []lexer.Token {
// 	if c.processed >= len(c.tokens) {
// 		return []lexer.Token{}
// 	}
// 	return c.tokens[c.processed:]
// }
// func (c *cursor) hasNext() bool {
// 	return c.processed < len(c.tokens)
// }

// // 次のトークンを返す
// func (c *cursor) peek() lexer.Token {
// 	return c.peekN(1)
// }

// // n個次のトークンを返す
// func (c *cursor) peekN(n int) lexer.Token {
// 	if c.processed+n-1 >= len(c.tokens) {
// 		return lexer.Token{}
// 	}
// 	return c.tokens[c.processed+n-1]
// }
