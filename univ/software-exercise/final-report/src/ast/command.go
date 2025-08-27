package ast

// AssignmentWord ::= <word> '=' <word>
type AssignmentWord struct {
	Name  *Word
	Value *Word
}

func (a *AssignmentWord) Pos() int { return 0 }
func (a *AssignmentWord) End() int { return 0 }

// Redirection ::= ... (see BNF)
type Redirection struct {
	Operator string
	Target   *Word
	Fd       *Word // optional, for cases like 2>file
}

func (r *Redirection) Pos() int { return 0 }
func (r *Redirection) End() int { return 0 }

// SimpleCommand ::= <simple_command_element>+
type SimpleCommand struct {
	Elements []Node // *Word, *AssignmentWord, *Redirection
}

func (s *SimpleCommand) Pos() int { return 0 }
func (s *SimpleCommand) End() int { return 0 }

// Pipeline ::= [!] <pipeline_command> ('|' <pipeline_command>)*
type Pipeline struct {
	Bang     bool
	Commands []*PipelineCommand
}

func (p *Pipeline) Pos() int { return 0 }
func (p *Pipeline) End() int { return 0 }

// PipelineCommand ::= <command>
type PipelineCommand struct {
	Cmd Node // *SimpleCommand or *ShellCommand
}

func (p *PipelineCommand) Pos() int { return 0 }
func (p *PipelineCommand) End() int { return 0 }
