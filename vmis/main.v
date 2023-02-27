module main

import os
import cli

fn main() {
    mut app := cli.Command{
        name: 'vmis'
        description: 'Misskey client written in Vlang'
        //execute: fn (cmd cli.Command) ! { }
        commands: [post_cmd()]
    }
    app.setup()
    app.parse(os.args)
}


fn post_cmd ()(cli.Command){
	mut cmd := cli.Command{
		name: 'post'
		execute: fn (cmd cli.Command) ! {
			println('hello subcommand')
			return
		}
	}

	return cmd
}
