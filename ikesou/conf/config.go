package conf

import (
	"encoding/json"
	"os"
	"path/filepath"
)

type Config struct {
	Provider string         `json:"provider"`
	OpenAI   OpenAIConfig `json:"openai,omitempty"`
	Ollama   OllamaConfig `json:"ollama,omitempty"`
	Bedrock  BedrockConfig `json:"bedrock,omitempty"`
}

type OpenAIConfig struct {
	Model  string `json:"model"`
	APIKey string `json:"api_key"`
}

type OllamaConfig struct {
	Model string `json:"model"`
}

type BedrockConfig struct {
	Model string `json:"model"`
	Region string `json:"region"`
}

func LoadConfig() (Config, error) {
	homeDir, err := os.UserHomeDir()
	if err != nil {
		return Config{}, err
	}

	configFile := filepath.Join(homeDir, ".ikesourc.json")
	file, err := os.Open(configFile)
	if os.IsNotExist(err) {
		// ファイルが存在しない場合はデフォルト設定を使用する
		return Config{
			Provider: "openai",
			OpenAI: OpenAIConfig{
				Model: "gpt-3.5-turbo",
				APIKey: "",
			},
		}, nil
	} else if err != nil {
		return Config{}, err
	}
	defer file.Close()

	decoder := json.NewDecoder(file)
	config := Config{}
	err = decoder.Decode(&config)
	return config, err
}
