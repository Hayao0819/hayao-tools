package parser

import (
	"fmt"
	"os"
	"strings"

	"github.com/Hayao0819/zash/go/ast"
	"github.com/Hayao0819/zash/go/internal/logmgr"
	"github.com/Hayao0819/zash/go/lexer"
)

type Parser struct {
	tokens []lexer.Token
	pos    int
}

func NewParser(tokens []lexer.Token) *Parser {
	return &Parser{
		tokens: tokens,
		pos:    0,
	}
}

func (p *Parser) Parse() (ast.Node, error) {
	// スクリプト全体のパースエントリポイント
	logmgr.Parser().Debug("Parse: start")
	script := &ast.Script{}
	node, err := p.parseList()
	if err != nil {
		logmgr.Parser().Debug("Parse: error", "err", err)
		return nil, err
	}
	script.List = node
	logmgr.Parser().Debug("Parse: end")
	// デバッグ有効時にASTを視覚的に出力
	if logmgr.IsEnabled("parser") {
		// インデントを維持したままstderrに出力
		fmt.Fprintln(os.Stderr, "===== AST tree =====")
		fmt.Fprint(os.Stderr, String(script))
		fmt.Fprintln(os.Stderr, "====================")
		logmgr.Parser().Debug("AST tree printed to stderr")
	}
	return script, nil
}

func (p *Parser) next() lexer.Token {
	if p.pos >= len(p.tokens) {
		return lexer.Token{}
	}
	tok := p.tokens[p.pos]
	p.pos++
	return tok
}

func (p *Parser) peek() lexer.Token {
	if p.pos >= len(p.tokens) {
		return lexer.Token{}
	}
	return p.tokens[p.pos]
}

func (p *Parser) expect(typ lexer.TokenType) (lexer.Token, bool) {
	tok := p.peek()
	if tok.Type == typ {
		p.next()
		return tok, true
	}
	return tok, false
}

// --- 以下BNFに対応する主要パース関数群 ---

func (p *Parser) parseList() (ast.Node, error) {
	// <list> ::= <newline_list> <list0>
	// <list0> ::= <list1> '\n' <newline_list> | ...
	// <list1> ::= ...
	// ここでは簡易的にパイプラインやコマンド列をリストとしてまとめる
	logmgr.Parser().Debug("parseList: start", "pos", p.pos)
	var items []ast.Node
	for {
		// EOTなら即終了
		if p.peek().Type == lexer.TokenEOT {
			logmgr.Parser().Debug("parseList: found EOT, break")
			break
		}
		n, err := p.parsePipeline()
		if err != nil {
			logmgr.Parser().Debug("parseList: pipeline error", "err", err)
			break
		}
		if n != nil {
			logmgr.Parser().Debug("parseList: add pipeline node")
			items = append(items, n)
		} else {
			logmgr.Parser().Debug("parseList: no more pipeline node")
			break
		}
		// 改行やセミコロンで区切る
		tok := p.peek()
		if tok.Type == lexer.TokenNewline || tok.Type == lexer.TokenSemicolon {
			logmgr.Parser().Debug("parseList: skip separator", "tok", lexer.TokenType(tok.Type).String())
			p.next()
			continue
		}
		// EOTなら終了
		if tok.Type == lexer.TokenEOT {
			logmgr.Parser().Debug("parseList: found EOT after pipeline, break")
			break
		}
		break
	}
	logmgr.Parser().Debug("parseList: end", "count", len(items))
	return &ast.List{Items: items}, nil
}

func (p *Parser) parsePipeline() (ast.Node, error) {
	// <pipeline> ::= [!] <command> ('|' <command>)*
	logmgr.Parser().Debug("parsePipeline: start", "pos", p.pos)
	bang := false
	if p.peek().Type == lexer.TokenBang {
		bang = true
		logmgr.Parser().Debug("parsePipeline: found ! (bang)")
		p.next()
	}
	cmds := []*ast.PipelineCommand{}
	for {
		// EOTなら即終了
		if p.peek().Type == lexer.TokenEOT {
			logmgr.Parser().Debug("parsePipeline: found EOT, break")
			break
		}
		cmd, err := p.parseCommand()
		if err != nil {
			logmgr.Parser().Debug("parsePipeline: command error", "err", err)
			return nil, err
		}
		if cmd == nil {
			logmgr.Parser().Debug("parsePipeline: no more command")
			break
		}
		logmgr.Parser().Debug("parsePipeline: add command to pipeline")
		cmds = append(cmds, &ast.PipelineCommand{Cmd: cmd})
		if p.peek().Type == lexer.TokenPipe {
			logmgr.Parser().Debug("parsePipeline: found | (pipe)")
			p.next()
			continue
		}
		// EOTなら終了
		if p.peek().Type == lexer.TokenEOT {
			logmgr.Parser().Debug("parsePipeline: found EOT after command, break")
			break
		}
		break
	}
	if len(cmds) == 0 {
		logmgr.Parser().Debug("parsePipeline: empty pipeline")
		return nil, nil
	}
	logmgr.Parser().Debug("parsePipeline: end", "count", len(cmds))
	return &ast.Pipeline{Bang: bang, Commands: cmds}, nil
}

func (p *Parser) parseCommand() (ast.Node, error) {
	// <command> ::= <simple_command> | <shell_command> | ...
	tok := p.peek()
	logmgr.Parser().Debug("parseCommand: start", "token", lexer.TokenType(tok.Type).String())
	switch tok.Type {
	case lexer.TokenIf:
		logmgr.Parser().Debug("parseCommand: if")
		return p.parseIfCommand()
	case lexer.TokenFor:
		logmgr.Parser().Debug("parseCommand: for")
		return p.parseForCommand()
	case lexer.TokenWhile:
		logmgr.Parser().Debug("parseCommand: while")
		return p.parseWhileCommand()
	case lexer.TokenUntil:
		logmgr.Parser().Debug("parseCommand: until")
		return p.parseUntilCommand()
	case lexer.TokenCase:
		logmgr.Parser().Debug("parseCommand: case")
		return p.parseCaseCommand()
	case lexer.TokenSelect:
		logmgr.Parser().Debug("parseCommand: select")
		return p.parseSelectCommand()
	case lexer.TokenLParen:
		logmgr.Parser().Debug("parseCommand: subshell")
		return p.parseSubshell()
	case lexer.TokenLBrace:
		logmgr.Parser().Debug("parseCommand: group")
		return p.parseGroupCommand()
	default:
		logmgr.Parser().Debug("parseCommand: simple command")
		return p.parseSimpleCommand()
	}
}

func (p *Parser) parseSimpleCommand() (ast.Node, error) {
	// <simple_command> ::= <simple_command_element>+
	logmgr.Parser().Debug("parseSimpleCommand: start", "pos", p.pos)
	elements := []ast.Node{}
	var wordBuf string
	for {
		tok := p.peek()
		logmgr.Parser().Debug("parseSimpleCommand: peek", "token", lexer.TokenType(tok.Type).String(), "text", tok.Text)
		switch tok.Type {
		case lexer.TokenWord, lexer.TokenString, lexer.TokenQuotedString, lexer.TokenEscapeChar, lexer.TokenSingleQuotedString:
			wordBuf += p.next().Text
		case lexer.TokenAssign:
			if wordBuf != "" {
				trimmed := strings.TrimSpace(wordBuf)
				if trimmed != "" {
					elements = append(elements, &ast.Word{Value: trimmed})
				}
				wordBuf = ""
			}
			logmgr.Parser().Debug("parseSimpleCommand: assign", "elements", len(elements))
			// 直前のWordを変数名とみなす
			if len(elements) > 0 {
				if w, ok := elements[len(elements)-1].(*ast.Word); ok {
					p.next() // '='
					valTok := p.next()
					elements[len(elements)-1] = &ast.AssignmentWord{
						Name:  w,
						Value: &ast.Word{Value: strings.TrimSpace(valTok.Text)},
					}
					continue
				}
			}
			p.next()
		case lexer.TokenRedirection:
			if wordBuf != "" {
				trimmed := strings.TrimSpace(wordBuf)
				if trimmed != "" {
					elements = append(elements, &ast.Word{Value: trimmed})
				}
				wordBuf = ""
			}
			logmgr.Parser().Debug("parseSimpleCommand: redirection", "text", tok.Text)
			elements = append(elements, &ast.Redirection{Operator: p.next().Text})
		case lexer.TokenWhitespace:
			if wordBuf != "" {
				trimmed := strings.TrimSpace(wordBuf)
				if trimmed != "" {
					elements = append(elements, &ast.Word{Value: trimmed})
				}
				wordBuf = ""
			}
			p.next()
		case lexer.TokenAnd:
			// バックグラウンド実行記号(&)は無視
			p.next()
		default:
			if wordBuf != "" {
				trimmed := strings.TrimSpace(wordBuf)
				if trimmed != "" {
					elements = append(elements, &ast.Word{Value: trimmed})
				}
				wordBuf = ""
			}
			logmgr.Parser().Debug("parseSimpleCommand: end", "elements", len(elements))
			return &ast.SimpleCommand{Elements: elements}, nil
		}
	}
}

// --- shell_command系 ---
func (p *Parser) parseIfCommand() (ast.Node, error) {
	// if <compound_list> then <compound_list> [else <compound_list>] fi
	logmgr.Parser().Debug("parseIfCommand: start")
	p.next() // 'if'
	cond, _ := p.parseList()
	p.expect(lexer.TokenThen)
	thenPart, _ := p.parseList()
	var elsePart ast.Node
	if p.peek().Type == lexer.TokenElse {
		p.next()
		elsePart, _ = p.parseList()
	}
	p.expect(lexer.TokenFi)
	logmgr.Parser().Debug("parseIfCommand: end")
	return &ast.ShellCommand{
		Kind: "if",
		Node: &ast.IfCommand{
			Cond: cond,
			Then: thenPart,
			Else: elsePart,
		},
	}, nil
}

func (p *Parser) parseForCommand() (ast.Node, error) {
	logmgr.Parser().Debug("parseForCommand: start")
	p.next() // 'for'
	varName := p.next()
	var words []*ast.Word
	if p.peek().Type == lexer.TokenIn {
		p.next()
		for p.peek().Type == lexer.TokenWord {
			words = append(words, &ast.Word{Value: p.next().Text})
		}
	}
	p.expect(lexer.TokenDo)
	body, _ := p.parseList()
	p.expect(lexer.TokenDone)
	logmgr.Parser().Debug("parseForCommand: end")
	return &ast.ShellCommand{
		Kind: "for",
		Node: &ast.ForCommand{
			Var:   &ast.Word{Value: varName.Text},
			Words: words,
			Body:  body,
		},
	}, nil
}

func (p *Parser) parseWhileCommand() (ast.Node, error) {
	logmgr.Parser().Debug("parseWhileCommand: start")
	p.next() // 'while'
	cond, _ := p.parseList()
	p.expect(lexer.TokenDo)
	body, _ := p.parseList()
	p.expect(lexer.TokenDone)
	logmgr.Parser().Debug("parseWhileCommand: end")
	return &ast.ShellCommand{
		Kind: "while",
		Node: &ast.WhileCommand{
			Cond: cond,
			Body: body,
		},
	}, nil
}

func (p *Parser) parseUntilCommand() (ast.Node, error) {
	logmgr.Parser().Debug("parseUntilCommand: start")
	p.next() // 'until'
	cond, _ := p.parseList()
	p.expect(lexer.TokenDo)
	body, _ := p.parseList()
	p.expect(lexer.TokenDone)
	logmgr.Parser().Debug("parseUntilCommand: end")
	return &ast.ShellCommand{
		Kind: "until",
		Node: &ast.UntilCommand{
			Cond: cond,
			Body: body,
		},
	}, nil
}

func (p *Parser) parseCaseCommand() (ast.Node, error) {
	logmgr.Parser().Debug("parseCaseCommand: start")
	p.next() // 'case'
	word := p.next()
	// 簡易実装: case ... esac
	for p.peek().Type != lexer.TokenEsac && p.pos < len(p.tokens) {
		p.next()
	}
	p.expect(lexer.TokenEsac)
	logmgr.Parser().Debug("parseCaseCommand: end")
	return &ast.ShellCommand{
		Kind: "case",
		Node: &ast.CaseCommand{
			Word:   &ast.Word{Value: word.Text},
			Clause: nil, // TODO: case_clauseの実装
		},
	}, nil
}

func (p *Parser) parseSelectCommand() (ast.Node, error) {
	logmgr.Parser().Debug("parseSelectCommand: start")
	p.next() // 'select'
	varName := p.next()
	var words []*ast.Word
	if p.peek().Type == lexer.TokenIn {
		p.next()
		for p.peek().Type == lexer.TokenWord {
			words = append(words, &ast.Word{Value: p.next().Text})
		}
	}
	p.expect(lexer.TokenDo)
	body, _ := p.parseList()
	p.expect(lexer.TokenDone)
	logmgr.Parser().Debug("parseSelectCommand: end")
	return &ast.ShellCommand{
		Kind: "select",
		Node: &ast.SelectCommand{
			Var:   &ast.Word{Value: varName.Text},
			Words: words,
			Body:  body,
		},
	}, nil
}

func (p *Parser) parseSubshell() (ast.Node, error) {
	logmgr.Parser().Debug("parseSubshell: start")
	p.next() // '('
	body, _ := p.parseList()
	p.expect(lexer.TokenRParen)
	logmgr.Parser().Debug("parseSubshell: end")
	return &ast.Subshell{Body: body}, nil
}

func (p *Parser) parseGroupCommand() (ast.Node, error) {
	logmgr.Parser().Debug("parseGroupCommand: start")
	p.next() // '{'
	body, _ := p.parseList()
	p.expect(lexer.TokenRBrace)
	logmgr.Parser().Debug("parseGroupCommand: end")
	return &ast.GroupCommand{Body: body}, nil
}
