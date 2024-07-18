package mobra

import "github.com/Hayao0819/nahi/cobrautils"

func (c *Command) CustomHelp(label *cobrautils.HelpLabels) *Command {
	cobrautils.UseCustomizableHelpTemplate(c.cc, label)
	return c
}
