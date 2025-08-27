package ast

// Comment represents a shell comment
type Comment struct {
	Text string
}

func (c *Comment) Pos() int { return 0 }
func (c *Comment) End() int { return 0 }

// Pattern ::= <word> | <pattern> '|' <word>
type Pattern struct {
	Words []*Word
}

func (p *Pattern) Pos() int { return 0 }
func (p *Pattern) End() int { return 0 }

// PatternList ::= ...
type PatternList struct {
	Patterns []*Pattern
	Body     Node // *CompoundList or nil
}

func (p *PatternList) Pos() int { return 0 }
func (p *PatternList) End() int { return 0 }

// CaseClause ::= <pattern_list> | <case_clause_sequence> <pattern_list>
type CaseClause struct {
	Clauses []*PatternList
}

func (c *CaseClause) Pos() int { return 0 }
func (c *CaseClause) End() int { return 0 }

// CaseClauseSequence ::= <pattern_list> ';;' | <case_clause_sequence> <pattern_list> ';;'
type CaseClauseSequence struct {
	Sequences []*PatternList
}

func (c *CaseClauseSequence) Pos() int { return 0 }
func (c *CaseClauseSequence) End() int { return 0 }
