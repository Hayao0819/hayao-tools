package lexer

// Lexer は字句解析を行う構造体。状態と解析対象の文字列を保持する。
type Lexer struct {
	state     state
	input     string
	processed int
}

// left は未処理の残り文字列を返す。
func (l *Lexer) left() string {
	return l.input[l.processed:]
}

// NewLexer は新しい Lexer を初期化して返す。
func NewLexer(input string) *Lexer {
	return &Lexer{
		state:     lexInitState,
		input:     input,
		processed: 0,
	}
}
