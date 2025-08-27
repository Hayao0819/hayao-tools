package parser

import (
	"fmt"
	"strings"

	"github.com/Hayao0819/zash/go/ast"
)

// String returns a visual tree representation of the AST.
func String(node ast.Node) string {
	var b strings.Builder
	printAST(&b, node, "")
	return b.String()
}

func printAST(b *strings.Builder, node ast.Node, indent string) {
	if node == nil {
		b.WriteString(indent + "<nil>\n")
		return
	}
	switch n := node.(type) {
	case *ast.Script:
		b.WriteString(indent + "Script\n")
		printAST(b, n.List, indent+"  ")
	case *ast.List:
		b.WriteString(indent + "List\n")
		for _, item := range n.Items {
			printAST(b, item, indent+"  ")
		}
	case *ast.Pipeline:
		b.WriteString(indent + "Pipeline (Bang=" + fmt.Sprint(n.Bang) + ")\n")
		for _, pc := range n.Commands {
			printAST(b, pc, indent+"  ")
		}
	case *ast.PipelineCommand:
		b.WriteString(indent + "PipelineCommand\n")
		printAST(b, n.Cmd, indent+"  ")
	case *ast.SimpleCommand:
		b.WriteString(indent + "SimpleCommand\n")
		for _, el := range n.Elements {
			printAST(b, el, indent+"  ")
		}
	case *ast.Word:
		b.WriteString(indent + "Word: '" + n.Value + "'\n")
	case *ast.AssignmentWord:
		b.WriteString(indent + "AssignmentWord\n")
		printAST(b, n.Name, indent+"  ")
		printAST(b, n.Value, indent+"  ")
	case *ast.Redirection:
		b.WriteString(indent + "Redirection: op='" + n.Operator + "'\n")
		printAST(b, n.Target, indent+"  ")
		printAST(b, n.Fd, indent+"  ")
	case *ast.ShellCommand:
		b.WriteString(indent + "ShellCommand: " + n.Kind + "\n")
		printAST(b, n.Node, indent+"  ")
	case *ast.IfCommand:
		b.WriteString(indent + "IfCommand\n")
		b.WriteString(indent + "  Cond:\n")
		printAST(b, n.Cond, indent+"    ")
		b.WriteString(indent + "  Then:\n")
		printAST(b, n.Then, indent+"    ")
		b.WriteString(indent + "  Else:\n")
		printAST(b, n.Else, indent+"    ")
	case *ast.ForCommand:
		b.WriteString(indent + "ForCommand\n")
		printAST(b, n.Var, indent+"  ")
		for _, w := range n.Words {
			printAST(b, w, indent+"  ")
		}
		printAST(b, n.Body, indent+"  ")
	case *ast.WhileCommand:
		b.WriteString(indent + "WhileCommand\n")
		b.WriteString(indent + "  Cond:\n")
		printAST(b, n.Cond, indent+"    ")
		b.WriteString(indent + "  Body:\n")
		printAST(b, n.Body, indent+"    ")
	case *ast.UntilCommand:
		b.WriteString(indent + "UntilCommand\n")
		b.WriteString(indent + "  Cond:\n")
		printAST(b, n.Cond, indent+"    ")
		b.WriteString(indent + "  Body:\n")
		printAST(b, n.Body, indent+"    ")
	case *ast.CaseCommand:
		b.WriteString(indent + "CaseCommand\n")
		printAST(b, n.Word, indent+"  ")
		printAST(b, n.Clause, indent+"  ")
	case *ast.SelectCommand:
		b.WriteString(indent + "SelectCommand\n")
		printAST(b, n.Var, indent+"  ")
		for _, w := range n.Words {
			printAST(b, w, indent+"  ")
		}
		printAST(b, n.Body, indent+"  ")
	case *ast.FunctionDef:
		b.WriteString(indent + "FunctionDef\n")
		printAST(b, n.Name, indent+"  ")
		printAST(b, n.Body, indent+"  ")
	case *ast.Subshell:
		b.WriteString(indent + "Subshell\n")
		printAST(b, n.Body, indent+"  ")
	case *ast.GroupCommand:
		b.WriteString(indent + "GroupCommand\n")
		printAST(b, n.Body, indent+"  ")
	case *ast.CompoundList:
		b.WriteString(indent + "CompoundList\n")
		printAST(b, n.List, indent+"  ")
	default:
		b.WriteString(indent + fmt.Sprintf("<unknown %T>\n", node))
	}
}
