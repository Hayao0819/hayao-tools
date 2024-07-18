package env

import (
	"fmt"

	"github.com/Hayao0819/Hayao-Tools/gistrge/utils"
	"github.com/cockroachdb/errors"
	"github.com/spf13/viper"
)

var globalConfig *config

var vp *viper.Viper

type config struct {
	GitHubToken          string `mapstructure:"github_token"`
	DescriptionRegExpStr string `mapstructure:"gist_description_regexp"`
	GistFileName         string `mapstructure:"gist_filename"`
}

func Config() *config {
	return globalConfig
}

func Default() *config {
	return &config{
		GitHubToken:          "",
		DescriptionRegExpStr: `^Gistrge: `,
		GistFileName:         "gistrge.txt",
	}

}

func Load() error {
	if err := vp.ReadInConfig(); err != nil {
		if _, ok := err.(viper.ConfigFileNotFoundError); !ok { // Ignore if file not found
			return errors.Wrap(err, "failed to read config file")
		}
	}

	globalConfig = Default()
	if err := vp.Unmarshal(globalConfig); err != nil {
		return errors.Wrap(err, "failed to unmarshal config")
	}

	fmt.Println(utils.JSON(globalConfig))

	return nil
}

func init() {
	vp = viper.New()

	// Config Files
	vp.SetConfigName("gistrgerc")
	vp.SetConfigType("json")

	vp.AddConfigPath(".")

	// Environment Variables
	vp.SetEnvPrefix("GISTRGE")
	vp.AutomaticEnv()

}
