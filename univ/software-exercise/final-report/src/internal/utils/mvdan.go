package utils

import (
	"encoding/json"
	"io"
	"strings"

	"mvdan.cc/sh/v3/syntax"
)

func Parse(r io.Reader, name string, opts ...syntax.ParserOption) (*syntax.File, error) {
	parser := syntax.NewParser(opts...)
	parsed, err := parser.Parse(r, name)
	if err != nil {
		return nil, err
	}

	return parsed, nil
}

func ParseString(line string) (*syntax.File, error) {
	return Parse(strings.NewReader(line), "stdin")
}

func AstJSON(node syntax.Node) ([]byte, error) {
	if node == nil {
		return nil, nil
	}
	return json.Marshal(node)

}
