package ast

// Node is the interface for all AST nodes
type Node interface {
	Pos() int // start position (optional, for future use)
	End() int // end position (optional, for future use)
}

// Script represents a shell script (top-level node)
type Script struct {
	List Node // usually *List or *CompoundList
}

// Word represents a shell word
type Word struct {
	Value string
}

func (w *Word) Pos() int { return 0 }
func (w *Word) End() int { return 0 }

func (s *Script) Pos() int { return 0 }
func (s *Script) End() int { return 0 }
