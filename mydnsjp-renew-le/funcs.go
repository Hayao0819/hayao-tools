package main

import (
	"errors"
	"fmt"
	"os"
	"strings"

	//"log"
	"net/http"
	"net/url"
	"reflect"

	//"strings"

	"github.com/caarlos0/env"
	"github.com/spf13/pflag"
)

/*
	--dry-run
	--delete
	--regist
*/

func parse_mode() error{
	args_dry_run := pflag.BoolP("dry-run", "x", false, "Show post data and url without send request.")
	args_delete := pflag.BoolP("delete", "d",  false, "Execute delete mode.")
	args_regist := pflag.BoolP("regist", "r", false, "Execute regist mode.")
	args_help := pflag.BoolP("help", "h", false, "Show help.")

	pflag.Parse()

	if *args_dry_run {
		current_mode = simulation
	}else if *args_delete {
		current_mode = delete
	}else if *args_regist {
		current_mode = regist
	}else if *args_help {
		pflag.Usage()
		os.Exit(0)
	}else{
		return errors.New("mode is none")
	}

	return nil
}

// ドメインをパース
// 構文: "ID:PASSWORD:DOMAIN"
func parse_domains () error{
	for _, arg := range pflag.Args() {
		arg_slice := strings.Split(arg, ":")
		if len(arg_slice) != 3 {
			return errors.New("domain parse error")
		}

		id 	:= arg_slice[0]
		pass 	:= arg_slice[1]
		domain  := arg_slice[2]

		if environ.Domain == domain{
			mydnsjp.Id = id
			mydnsjp.Pass = pass
		}
		
	}
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
