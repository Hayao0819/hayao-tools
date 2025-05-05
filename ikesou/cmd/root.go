package cmd

import (
	"bufio"
	"context"
	"fmt"
	"os"

	"github.com/Hayao0819/Hayao-Tools/ikesou/conf"
	"github.com/spf13/cobra"
	"github.com/tmc/langchaingo/llms"
	"github.com/tmc/langchaingo/llms/ollama"
	"github.com/tmc/langchaingo/llms/openai"
)

func rootCmd() *cobra.Command {
	cmd := &cobra.Command{
		Use:   "ikesou",
		Short: "curl | bash のようなリモートコード実行のパイプラインに挟み、LLMで安全性を検証するツール",
		Long: `このツールは、curl | bash のようにリモートからコードを実行する際に、そのコードの安全性をLLMを用いて検証するためのものです。
安全であると判断された場合のみコードが実行され、そうでない場合は実行が中断されます。
LangChainGoを用いてLLMを呼び出します。`,
		Run: func(cmd *cobra.Command, args []string) {
			// 設定ファイルを読み込む
			config, err := conf.LoadConfig()
			if err != nil {
				cmd.PrintErrln("設定ファイルの読み込みエラー:", err)
				os.Exit(1)
			}

			var llm llms.Model
			// プロバイダに応じてLLMを初期化する
			switch config.Provider {
			case "openai":
				llm, err = openai.New(openai.WithModel(config.OpenAI.Model), openai.WithToken(config.OpenAI.APIKey))
				if err != nil {
					cmd.PrintErrln("LLMの初期化エラー:", err)
					os.Exit(1)
				}
			case "ollama":
				llm, err = ollama.New(ollama.WithModel(config.Ollama.Model))
				if err != nil {
					cmd.PrintErrln("LLMの初期化エラー:", err)
					os.Exit(1)
				}
			case "bedrock":
				// Bedrockの初期化は未実装
				cmd.PrintErrln("Bedrockの初期化は未実装です")
				os.Exit(1)
			default:
				cmd.PrintErrln("プロバイダがサポートされていません:", config.Provider)
				os.Exit(1)
			}

			// 標準入力からソースコードを読み取る
			scanner := bufio.NewScanner(os.Stdin)
			var sourceCode string
			for scanner.Scan() {
				sourceCode += scanner.Text() + "\n"
			}
			if err := scanner.Err(); err != nil {
				cmd.PrintErrln("標準入力からの読み取りエラー:", err)
				os.Exit(1)
			}

			prompt := fmt.Sprintf("このソースコードは安全ですか？安全であれば「安全」と、そうでなければ「危険」と答えてください:\\n%s", sourceCode)
			result, err := llm.Call(context.Background(), prompt)
			if err != nil {
				cmd.PrintErrln("LLMの呼び出しエラー:", err)
				os.Exit(1)
			}

			// LLMの応答を解析する
			if result == "安全" {
				// ソースコードを標準出力に出力する
				cmd.Print(sourceCode)
			} else {
				// 何も出力せずに終了する
				cmd.PrintErrln("ソースコードは安全ではありません:", result)
				os.Exit(1)
			}
		},
	}
	return cmd
}

func Execute() error {
	cmd := rootCmd()
	err := cmd.Execute()
	if err != nil {
		cmd.PrintErrln(err)
		return err
	}
	return nil
}
