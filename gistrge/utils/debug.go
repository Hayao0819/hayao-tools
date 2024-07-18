package utils

import (
	"encoding/json"
)

func JSON(v any) string {
	json, err := json.Marshal(v)
	if err != nil {
		panic(err)
	}

	return string(json)
}
