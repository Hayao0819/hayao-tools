package mobra

import (
	"github.com/Hayao0819/nahi/cobrautils"
	"github.com/spf13/cobra"
	"github.com/spf13/viper"
)

type Command struct {
	cc *cobra.Command
}

func New(use string) *Command {
	c := Command{cc: &cobra.Command{}}
	return c.Use(use)
}

func (c *Command) Use(use string) *Command {
	c.cc.Use = use
	return c
}

func (c *Command) Aliases(aliases []string) *Command {
	c.cc.Aliases = aliases
	return c
}

// SetSuggestFor
func (c *Command) SuggestFor(suggestFor []string) *Command {
	c.cc.SuggestFor = suggestFor
	return c
}

func (c *Command) Short(short string) *Command {
	c.cc.Short = short
	return c
}

// SetGroupID
func (c *Command) GroupID(groupID string) *Command {
	c.cc.GroupID = groupID
	return c
}

func (c *Command) Long(long string) *Command {
	c.cc.Long = long
	return c
}

func (c *Command) Example(example string) *Command {
	c.cc.Example = example
	return c
}

func (c *Command) ValidArgs(validArgs []string) *Command {
	c.cc.ValidArgs = validArgs
	return c
}

func (c *Command) ValidArgsFunction(validArgsFunction func(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective)) *Command {
	c.cc.ValidArgsFunction = validArgsFunction
	return c
}

func (c *Command) Args(args cobra.PositionalArgs) *Command {
	c.cc.Args = args
	return c
}

func (c *Command) ArgAliases(argAliases []string) *Command {
	c.cc.ArgAliases = argAliases
	return c
}

func (c *Command) Deprecated(deprecated string) *Command {
	c.cc.Deprecated = deprecated
	return c
}

func (c *Command) Annotation(key, value string) *Command {
	c.cc.Annotations[key] = value
	return c
}

func (c *Command) Version(version string) *Command {
	c.cc.Version = version
	return c
}

// Funcs

func (c *Command) Run(f func(cmd *cobra.Command, args []string)) *Command {
	c.cc.Run = f
	return c
}

func (c *Command) RunE(f func(cmd *cobra.Command, args []string) error) *Command {
	c.cc.RunE = f
	return c
}

func (c *Command) PreRun(f func(cmd *cobra.Command, args []string)) *Command {
	c.cc.PreRun = f
	return c
}

func (c *Command) PreRunE(f func(cmd *cobra.Command, args []string) error) *Command {
	c.cc.PreRunE = f
	return c
}

func (c *Command) PersistentPreRun(f func(cmd *cobra.Command, args []string)) *Command {
	c.cc.PersistentPreRun = f
	return c
}

func (c *Command) PersistentPreRunE(f func(cmd *cobra.Command, args []string) error) *Command {
	c.cc.PersistentPreRunE = f
	return c
}

func (c *Command) PostRun(f func(cmd *cobra.Command, args []string)) *Command {
	c.cc.PostRun = f
	return c
}

func (c *Command) PostRunE(f func(cmd *cobra.Command, args []string) error) *Command {
	c.cc.PostRunE = f
	return c
}

func (c *Command) PersistentPostRun(f func(cmd *cobra.Command, args []string)) *Command {
	c.cc.PersistentPostRun = f
	return c
}

func (c *Command) PersistentPostRunE(f func(cmd *cobra.Command, args []string) error) *Command {
	c.cc.PersistentPostRunE = f
	return c
}

func (c *Command) PersistentPreRunWithParent(f func(cmd *cobra.Command, args []string)) *Command {
	c.cc.PersistentPreRun = cobrautils.WithParentPersistentPreRun(f)
	return c
}

func (c *Command) PersistentPreRunEWithParent(f func(cmd *cobra.Command, args []string) error) *Command {
	c.cc.PersistentPreRunE = cobrautils.WithParentPersistentPreRunE(f)
	return c
}

func (c *Command) PersistentPostRunWithParent(f func(cmd *cobra.Command, args []string)) *Command {
	c.cc.PersistentPostRun = cobrautils.WithParentPersistentPostRun(f)
	return c
}

func (c *Command) PersistentPostRunEWithParent(f func(cmd *cobra.Command, args []string) error) *Command {
	c.cc.PersistentPostRunE = cobrautils.WithParentPersistentPostRunE(f)
	return c
}

// Hidden

func (c *Command) Hidden(hidden bool) *Command {
	c.cc.Hidden = hidden
	return c
}

func (c *Command) Hide() *Command {
	c.Hidden(true)
	return c
}

func (c *Command) Show() *Command {
	c.Hidden(false)
	return c
}

// Errors

func (c *Command) SetSilenceErrors(silenceErrors bool) *Command {
	c.cc.SilenceErrors = silenceErrors
	return c
}

func (c *Command) PrintErrors() *Command {
	c.SetSilenceErrors(false)
	return c
}

func (c *Command) HideErrors() *Command {
	c.SetSilenceErrors(true)
	return c
}

// Usage

func (c *Command) SetSilenceUsage(silenceUsage bool) *Command {
	c.cc.SilenceUsage = silenceUsage
	return c
}

func (c *Command) PrintUsage() *Command {
	c.SetSilenceUsage(false)
	return c
}

func (c *Command) HideUsage() *Command {
	c.SetSilenceUsage(true)
	return c
}

func (c *Command) SetDisableFlagParsing(disableFlagParsing bool) *Command {
	c.Cobra().DisableFlagParsing = disableFlagParsing
	return c
}

func (c *Command) SetDisableAutoGenTag(disableAutoGenTag bool) *Command {
	c.cc.DisableAutoGenTag = disableAutoGenTag
	return c
}

func (c *Command) SetDisableFlagsInUseLine(disableFlagsInUseLine bool) *Command {
	c.cc.DisableFlagsInUseLine = disableFlagsInUseLine
	return c
}

func (c *Command) SetDisableSuggestions(disableSuggestions bool) *Command {
	c.cc.DisableSuggestions = disableSuggestions
	return c
}

func (c *Command) SetSuggestionsMinimumDistance(suggestionsMinimumDistance int) *Command {
	c.cc.SuggestionsMinimumDistance = suggestionsMinimumDistance
	return c
}

func (c *Command) DisableCompletion() *Command {
	c.cc.CompletionOptions.DisableDefaultCmd = true
	return c
}

func (c *Command) DisableHelpCommand() *Command {
	c.cc.SetHelpCommand(&cobra.Command{})
	return c
}

// utils

func (c *Command) DisableDefaultCmd() *Command {
	return c.DisableCompletion().DisableHelpCommand()
}

func (c *Command) Cobra() *cobra.Command {
	return c.cc
}

// subcmd
func (c *Command) BindSubCmds(r *cobrautils.Registory) *Command {
	r.Bind(c.Cobra())
	return c
}

// Viper
func (c *Command) BindViper(v *viper.Viper) *Command {
	v.BindPFlags(c.cc.Flags())
	return c
}
