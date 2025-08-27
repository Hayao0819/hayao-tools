package prompt

import (
	"fmt"
	"log/slog"
	"os"

	"golang.org/x/sync/errgroup"
)

func (p *Prompt) Update() error {
	eg := new(errgroup.Group)
	eg.Go(p.UpdateUser)
	eg.Go(p.UpdateCurrentDir)
	return eg.Wait()
}

func (p *Prompt) UpdateUser() error {
	user := os.Getenv("USER")
	if user == "" {
		return fmt.Errorf("user not found")
	}
	slog.Debug("PromptUpdateUser", "user", user)
	p.user = user
	return nil
}

func (p *Prompt) UpdateCurrentDir() error {
	currentDir, err := os.Getwd()
	if err != nil {
		return err
	}
	slog.Debug("PromptUpdateCurrentDir", "dir", currentDir)
	p.currentDir = currentDir
	return nil
}

func (p *Prompt) SetExitCode(code int) {
	p.exitCode = code
}
