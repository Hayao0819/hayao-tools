package prompt

import (
	"fmt"
	"io"
	"log/slog"
	"os"
	"strings"
)

func (p *Prompt) String() string {
	// ベース
	promptStr := "Wanya?"

	// 終了コード
	if p.exitCode != 0 {
		slog.Info("exit", "code", p.exitCode)
		promptStr = fmt.Sprintf("%s [exit %d]", promptStr, p.exitCode)
	}

	// ユーザ名
	if p.user != "" {
		promptStr = fmt.Sprintf("%s | %s", promptStr, p.user)
	}

	// カレントディレクトリ
	if p.currentDir != "" {
		show := strings.Replace(p.currentDir, os.Getenv("HOME"), "~", 1)
		promptStr = fmt.Sprintf("%s | %s", promptStr, show)
	}

	// 表示
	promptStr = fmt.Sprintf("%s > ", promptStr)
	return promptStr
}

func (p *Prompt) PromptWriter(w io.Writer) (int, error) {
	return io.WriteString(w, p.String())
}
