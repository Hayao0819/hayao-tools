package lexer

import (
	"github.com/Hayao0819/zash/go/internal/logmgr"
)

// GetNextState は次に遷移すべき状態を返す。
func (l *Lexer) getNextState() state {
	// 現在の状態に応じて次の状態を決定する
	logmgr.Lexer().Debug("getNextState: called", "current_state", l.state.name, "remaining", l.left())
	for _, s := range states {
		if s.determineFunc != nil && s.determineFunc(l) {
			logmgr.Lexer().Debug("getNextState: transition", "from", l.state.name, "to", s.name)
			l.state = s
			return s
		}
	}
	logmgr.Lexer().Debug("getNextState: fallback to init", "current_state", l.state.name)
	return lexInitState
}

// NextToken は現在の状態に応じて次のトークンを切り出して返す。
func (l *Lexer) NextToken() (*Token, error) {
	// すべての文字が処理されていた場合
	if len(l.left()) == 0 {
		logmgr.Lexer().Debug("NextToken: EOT reached")
		return &Token{
			Type: TokenEOT,
			Text: "",
		}, nil
	}

	logmgr.Lexer().Debug("NextToken: start", "state", l.state.name, "remaining", l.left())

	// 状態に応じて適切な処理を実行
	switch l.state.name {
	case lexInitState.name:
		logmgr.Lexer().Debug("NextToken: in init state, getNextState")
		l.state = l.getNextState()
		return l.NextToken()
	default:
		logmgr.Lexer().Debug("NextToken: using state lexFunc", "state", l.state.name)
		return l.state.lexFunc(l)
	}
}

// lexWhile は matchFn が true を返す限り文字を読み進め、トークンを切り出す共通処理。
func (l *Lexer) lexWhile(t TokenType, matchFn func(byte) bool) (*Token, error) {
	remaining := l.left()
	logmgr.Lexer().Debug("lexWhile: start", "type", t.String(), "remaining", remaining)
	i := 0
	for i < len(remaining) && matchFn(remaining[i]) {
		i++
	}

	// トークンを切り出し、残りの入力に更新
	token := remaining[:i]
	logmgr.Lexer().Debug("lexWhile: token extracted", "token", token, "length", i)
	l.processed += i

	// 状態を初期状態にリセット
	l.state = lexInitState
	logmgr.Lexer().Debug("lexWhile: state reset to init")
	return &Token{
		Type: t,
		Text: token,
	}, nil
}
