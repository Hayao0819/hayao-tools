package main

import (
	"log"
)



func main(){
	err := run()
	if err != nil {
		log.Fatalln(err)
	}
}

func run() error{
	funcs := []func() error{
		parse_args,
		get_env,
		check_env,
		make_req,
		send_req,
	}

	for _, f := range funcs {
		if err := f(); err != nil {
			return err
		}
	}
	return nil
}


