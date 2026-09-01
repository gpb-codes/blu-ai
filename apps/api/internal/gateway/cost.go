package gateway

type ModelPrice struct {
	InputPerM  float64
	OutputPerM float64
}

var prices = map[string]ModelPrice{
	"claude-opus-4-8":     {InputPerM: 15, OutputPerM: 75},
	"claude-sonnet-5":     {InputPerM: 3, OutputPerM: 15},
	"gpt-5":               {InputPerM: 1.25, OutputPerM: 10},
	"gpt-4o-mini":         {InputPerM: 0.15, OutputPerM: 0.6},
	"gemini-flash":        {InputPerM: 0.075, OutputPerM: 0.3},
	"deepseek-chat":       {InputPerM: 0.27, OutputPerM: 1.1},
	"qwen-finetune-light": {InputPerM: 0.1, OutputPerM: 0.3},
}

func CostUsd(model string, inputTokens, outputTokens int) float64 {
	p, ok := prices[model]
	if !ok {
		p = ModelPrice{InputPerM: 1, OutputPerM: 2}
	}
	return float64(inputTokens)/1_000_000*p.InputPerM + float64(outputTokens)/1_000_000*p.OutputPerM
}

var CreditWeights = map[string]int{
	"gpt-4o-mini":         1,
	"gemini-flash":        1,
	"deepseek-chat":       1,
	"claude-sonnet-5":     15,
	"gpt-5":               25,
	"claude-opus-4-8":     60,
	"qwen-finetune-light": 1,
}

func CreditsForModel(model string) int {
	if w, ok := CreditWeights[model]; ok {
		return w
	}
	return 5
}
