package env

import "regexp"

var descriptionRegExp *regexp.Regexp

func initDescriptionRegExp() error {
	var err error
	descriptionRegExp, err = regexp.Compile(DescriptionRegExpStr)
	return err
}

func UseDescriptionRegExp() (*regexp.Regexp, error) {
	if descriptionRegExp == nil {
		if err := initDescriptionRegExp(); err != nil {
			return nil, err
		}
	}
	return descriptionRegExp, nil
}
