package shell

import "github.com/Hayao0819/zash/go/internal/logmgr"

func (s *Shell) StartInteractive() {
	if s.started {
		return
	}
	s.started = true
	s.Println("Welcome to Zash!")

	for {
		i, err := s.prompt.WaitInput()
		if err != nil {
			// s.Println(err.Error())
			logmgr.Shell().Error("ShellWaitInput", "error", err)
			continue
		}
		if err := s.Run(i); err != nil {
			s.Println(err.Error())
		}
		if err := s.prompt.Update(); err != nil {
			logmgr.Shell().Error("ShellPromptUpdate", "error", err)
		}
	}
}
