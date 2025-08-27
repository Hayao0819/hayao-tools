package ast

// ShellCommand ::= if/for/while/case/select/subshell/group/function
type ShellCommand struct {
	Kind string // "if", "for", ...
	Node Node   // *IfCommand, *ForCommand, ...
}

func (s *ShellCommand) Pos() int { return 0 }
func (s *ShellCommand) End() int { return 0 }

type IfCommand struct {
	Cond Node // *CompoundList
	Then Node // *CompoundList
	Else Node // *CompoundList or *IfCommand or nil
}

func (i *IfCommand) Pos() int { return 0 }
func (i *IfCommand) End() int { return 0 }

type ForCommand struct {
	Var   *Word
	Words []*Word // word_list
	Body  Node    // *CompoundList
}

func (f *ForCommand) Pos() int { return 0 }
func (f *ForCommand) End() int { return 0 }

type WhileCommand struct {
	Cond Node // *CompoundList
	Body Node // *CompoundList
}

func (w *WhileCommand) Pos() int { return 0 }
func (w *WhileCommand) End() int { return 0 }

type UntilCommand struct {
	Cond Node // *CompoundList
	Body Node // *CompoundList
}

func (u *UntilCommand) Pos() int { return 0 }
func (u *UntilCommand) End() int { return 0 }

type CaseCommand struct {
	Word   *Word
	Clause Node // *CaseClause or *CaseClauseSequence
}

func (c *CaseCommand) Pos() int { return 0 }
func (c *CaseCommand) End() int { return 0 }

type SelectCommand struct {
	Var   *Word
	Words []*Word
	Body  Node // *List
}

func (s *SelectCommand) Pos() int { return 0 }
func (s *SelectCommand) End() int { return 0 }

type FunctionDef struct {
	Name *Word
	Body Node // *GroupCommand
}

func (f *FunctionDef) Pos() int { return 0 }
func (f *FunctionDef) End() int { return 0 }

type Subshell struct {
	Body Node // *CompoundList
}

func (s *Subshell) Pos() int { return 0 }
func (s *Subshell) End() int { return 0 }

type GroupCommand struct {
	Body Node // *List
}

func (g *GroupCommand) Pos() int { return 0 }
func (g *GroupCommand) End() int { return 0 }

type CompoundList struct {
	List Node // *List
}

func (c *CompoundList) Pos() int { return 0 }
func (c *CompoundList) End() int { return 0 }

type List struct {
	Items []Node // *List0, *List1, *SimpleList, etc.
}

func (l *List) Pos() int { return 0 }
func (l *List) End() int { return 0 }
