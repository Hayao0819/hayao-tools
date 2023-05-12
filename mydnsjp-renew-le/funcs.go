package main

import (
	"errors"
	"fmt"
	"strings"

	//"log"
	"net/http"
	"net/url"
	"reflect"

	//"strings"

	"github.com/caarlos0/env"
)

func parse_args() error{
	current_mode = simulation

	return nil
}

func get_env() error{
	return env.Parse(&environ)
}

func check_env()error{
	t := reflect.TypeOf(environ)
	enpty := []string{}
	for i := 0; i < t.NumField(); i++ {
		if strings.TrimSpace(reflect.ValueOf(&environ).Elem().Field(i).String()) == "" {
			enpty = append(enpty, t.Field(i).Tag.Get("env"))
		}
	}

	if len(enpty) > 0 {
		return errors.New(strings.Join(enpty, ", ") + " is empty")
	}
	return nil

}

func make_req() error{
	base, _ := url.Parse("https://www.mydns.jp/directedit.html")
	values := url.Values{}
	var err error

	// EDIT_CMD
	if current_mode == regist || current_mode == simulation{
		values.Add("EDIT_CMD", "REGIST")
	}else if current_mode == delete{
		values.Add("EDIT_CMD", "DELETE")
	}else{
		return errors.New("current_mode is none")
	}

	// DOMAIN
	values.Add("CERTBOT_DOMAIN", environ.Domain)

	// VALIDATION
	values.Add("CERTBOT_VALIDATION", environ.Validation)


	// Req
	request, err = http.NewRequest("POST", (*base).String(), strings.NewReader(values.Encode()))
	if err != nil {
		return err
	}

	request.Header.Add("Content-Type", "application/x-www-form-urlencoded")

	if current_mode == simulation{
		fmt.Println(values.Encode())
	}

	return nil
}

func send_req() error{
	if current_mode == simulation {
		fmt.Println(request.Header)
		fmt.Println(request.URL.String())
		return nil
	}

	client := &http.Client{}
	resp, err := client.Do(request)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	return nil
}
