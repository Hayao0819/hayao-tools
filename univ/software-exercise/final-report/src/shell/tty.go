package shell

import (
	"github.com/Hayao0819/zash/go/internal/utils"
)

func (s *Shell) Print(a ...any) {
	utils.TTYPrint(s.TTY, a...)
}
func (s *Shell) Println(a ...any) {
	utils.TTYPrintln(s.TTY, a...)
}

func (s *Shell) Close() {
	s.TTY.Close()
}
