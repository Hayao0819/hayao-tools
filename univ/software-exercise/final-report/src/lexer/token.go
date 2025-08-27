package lexer

import "encoding/json"

type TokenType int

const (
	_                       TokenType = iota
	TokenWhitespace                   // " " character
	TokenEscapeChar                   // \\ character
	TokenQuoteChar                    // " character
	TokenQuotedString                 // "string"
	TokenSingleQuoteChar              // ' character
	TokenSingleQuotedString           // 'string'
	TokenString                       // string
	TokenNumber                       // 123456
	TokenRedirection                  // > or <
	TokenComment                      // # character
	TokenPipe                         // | character
	TokenAnd                          // & character
	TokenUnknown                      // unknown token
	TokenEOT                          // End of Text

	// --- BNFに必要なキーワード・記号トークン ---
	TokenIf
	TokenThen
	TokenElse
	TokenElif
	TokenFi
	TokenFor
	TokenWhile
	TokenUntil
	TokenDo
	TokenDone
	TokenCase
	TokenEsac
	TokenSelect
	TokenIn
	TokenFunction
	TokenLBrace    // {
	TokenRBrace    // }
	TokenLParen    // (
	TokenRParen    // )
	TokenSemicolon // ;
	TokenNewline   // \n
	TokenAssign    // =
	TokenBang      // !
	TokenWord      // bare word (identifier, not keyword)
)

func (t TokenType) String() string {
	names := []string{
		"_",
		"Whitespace",
		"EscapeChar",
		"QuoteChar",
		"QuotedString",
		"SingleQuoteChar",
		"SingleQuotedString",
		"String",
		"Number",
		"Redirection",
		"Comment",
		"Pipe",
		"And",
		"Unknown",
		"EOT",
		// --- BNF tokens ---
		"If",
		"Then",
		"Else",
		"Elif",
		"Fi",
		"For",
		"While",
		"Until",
		"Do",
		"Done",
		"Case",
		"Esac",
		"Select",
		"In",
		"Function",
		"LBrace",
		"RBrace",
		"LParen",
		"RParen",
		"Semicolon",
		"Newline",
		"Assign",
		"Bang",
		"Word",
	}
	if int(t) < len(names) {
		return names[t]
	}
	return "UnknownTokenType"
}

type Token struct {
	Type TokenType
	Text string
}

func (t Token) String() string {
	if t.Type == TokenWhitespace {
		return " "
	}
	if t.Type == TokenEOT {
		return ""
	}
	if t.Type == TokenEscapeChar {
		return t.Text[1:]
	}
	return t.Text
}

func (t *Token) JSON() []byte {
	tj := struct {
		Type string `json:"type"`
		Text string `json:"text,omitempty"`
	}{
		Type: t.Type.String(),
		Text: t.Text,
	}
	j, _ := json.Marshal(tj)
	return j
}
