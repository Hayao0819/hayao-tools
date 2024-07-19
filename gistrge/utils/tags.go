package utils

import "reflect"

func GetTags(v any, tag string) []string {
	vType := reflect.TypeOf(v)
	ret := []string{}
	for i := range make([]struct{}, vType.NumField()) {
		tagStr := vType.Field(i).Tag.Get(tag)
		if tagStr != "" {
			ret = append(ret, tagStr)
		}
	}
	return ret
}
