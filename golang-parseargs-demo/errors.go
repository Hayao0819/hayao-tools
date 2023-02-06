package main

type ErrNoArg struct{
	Arg string
}

func (e *ErrNoArg)Error()(string){
	return "必要な引数がありません"
}

