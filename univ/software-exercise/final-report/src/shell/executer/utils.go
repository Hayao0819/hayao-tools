package executer

import (
	"os"
	"os/exec"
	"path"
	"path/filepath"
	"strings"
)

// resolveExecPath は与えられたコマンド名から実行可能な絶対パスを解決します。
func resolveExecPath(cmd string) (string, error) {
	if strings.Contains(cmd, string(os.PathSeparator)) {
		// パス区切り文字を含んでいる場合（例: ./foo、/bin/ls）
		if path.IsAbs(cmd) {
			return cmd, nil
		}
		return filepath.Abs(cmd)
	}
	// 環境変数 PATH を使って検索
	return exec.LookPath(cmd)
}
