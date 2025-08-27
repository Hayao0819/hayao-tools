package shell

import (
	"fmt"
	"reflect"

	"github.com/Hayao0819/zash/go/ast"
	"github.com/Hayao0819/zash/go/internal/logmgr"
	"github.com/Hayao0819/zash/go/shell/builtin"
	"github.com/Hayao0819/zash/go/shell/executer"
)

// ASTノード種別ごとに再帰的に実行する
func (s *Shell) ExecNode(node ast.Node) (int, error) {
	switch n := node.(type) {
	case *ast.Script:
		return s.ExecNode(n.List)
	case *ast.List:
		var last int
		for _, item := range n.Items {
			ec, err := s.ExecNode(item)
			if err != nil {
				return ec, err
			}
			last = ec
		}
		return last, nil
	case *ast.Pipeline:
		// 左から順にコマンドを実行し、最後の終了コードを返す（パイプ処理は簡易）
		var last int
		for _, pc := range n.Commands {
			ec, err := s.ExecNode(pc.Cmd)
			if err != nil {
				return ec, err
			}
			last = ec
		}
		return last, nil
	case *ast.SimpleCommand:
		return s.Exec(n)
	case *ast.ShellCommand:
		logmgr.Shell().Debug("ShellExecShellCommand", "kind", n.Kind)
		switch n.Kind {
		case "if":
			ifc := n.Node.(*ast.IfCommand)
			cond, _ := s.ExecNode(ifc.Cond)
			if cond == 0 {
				return s.ExecNode(ifc.Then)
			} else if ifc.Else != nil {
				return s.ExecNode(ifc.Else)
			}
			return 0, nil
		case "for":
			fc := n.Node.(*ast.ForCommand)
			var last int
			for range fc.Words {
				// 変数展開は未実装: 環境変数にセットする場合はここで
				last, _ = s.ExecNode(fc.Body)
			}
			return last, nil
		case "while":
			wc := n.Node.(*ast.WhileCommand)
			var last int
			for {
				logmgr.Shell().Debug("ShellExecWhileCommand", "condition", wc.Cond)
				cond, _ := s.ExecNode(wc.Cond)
				if cond != 0 { // 条件が偽（非0）の場合にループを終了
					break
				}
				last, _ = s.ExecNode(wc.Body)
			}
			return last, nil
		case "until":
			uc := n.Node.(*ast.UntilCommand)
			var last int
			for {
				cond, _ := s.ExecNode(uc.Cond)
				if cond == 0 {
					break
				}
				last, _ = s.ExecNode(uc.Body)
			}
			return last, nil
		case "select":
			// select文はforと同様に処理（簡易）
			sc := n.Node.(*ast.SelectCommand)
			var last int
			for range sc.Words {
				last, _ = s.ExecNode(sc.Body)
			}
			return last, nil
		case "case":
			// case文は未実装: 必要に応じてパターンマッチを追加
			return 0, nil
		case "function":
			// function定義は未実装: 必要に応じて関数テーブルに登録
			return 0, nil
		}
		return 0, nil
	case *ast.Subshell:
		// サブシェルは新しいShellインスタンスで実行するのが理想だが、ここでは再帰で代用
		return s.ExecNode(n.Body)
	case *ast.GroupCommand:
		return s.ExecNode(n.Body)
	case *ast.CompoundList:
		return s.ExecNode(n.List)
	default:
		return 0, fmt.Errorf("unsupported AST node: %v", reflect.TypeOf(node))
	}
}

// 指定されたコマンドが内部コマンドかどうかを判定
func (s *Shell) IsInternalCmd(cmd string) bool {
	return builtin.Cmds.Get(cmd) != nil
}

// 指定されたコマンドに基づいて適切なExecuterを取得
func (sn *Shell) getExecuter(cmd *ast.SimpleCommand) executer.Executer {
	name := ""
	for _, el := range cmd.Elements {
		if w, ok := el.(*ast.Word); ok {
			name = w.Value
			break
		}
	}
	var ex executer.Executer
	if sn.IsInternalCmd(name) {
		ex = &executer.InternalExecuter{}
	} else {
		ex = &executer.ExternalExecuter{}
	}
	return ex
}

func (s *Shell) defaultIOContext() executer.IOContext {
	return executer.IOContext{
		Stdin:  s.TTY.Input(),
		Stdout: s.TTY.Output(),
		Stderr: s.TTY.Output(),
	}
}

// SimpleCommand専用: ExecNodeから呼ばれる
func (s *Shell) Exec(cmd *ast.SimpleCommand) (int, error) {
	if cmd == nil || len(cmd.Elements) == 0 {
		return 0, nil
	}

	ioctx := s.defaultIOContext()

	// コマンド名・引数・リダイレクト抽出
	var name string
	var args []string
	var redirs []*ast.Redirection
	for _, el := range cmd.Elements {
		switch v := el.(type) {
		case *ast.Word:
			if name == "" {
				name = v.Value
			} else {
				args = append(args, v.Value)
			}
		case *ast.Redirection:
			redirs = append(redirs, v)
		}
	}

	if len(redirs) != 0 {
		logmgr.Shell().Debug("ShellParsedCommand", "name", name, "args", args)
		for _, r := range redirs {
			logmgr.Shell().Debug("ShellExecRedirection", "operator", r.Operator, "target", r.Target)
			if r.Target != nil {
				if err := ioctx.Redirect(r.Operator, r.Target.Value); err != nil {
					return 1, err
				}
			}
		}
	}

	ex := s.getExecuter(cmd)
	argv := append([]string{name}, args...)
	ec, err := ex.Exec(argv, ioctx)
	s.prompt.SetExitCode(ec)
	return ec, err
}
