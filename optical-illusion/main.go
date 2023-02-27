package main

import (
	"fmt"
	"os"
	"strconv"
)


var Size int =20
var Width int
var Height int

var (
	HidariUe="┏"
	HidariSita="┗"
	MigiUe="┓"
	MigiSita="┛"
	Yoko="━"
	Tate="┃"
	AidaUe="┳"
	AidaSita="┻"
	AidaHidari="┣"
	AidaMigi="┫"
	Cross="╋"
)

func startColor(){
	fmt.Printf("\033[30;47m")
}

func endColor(){
	fmt.Printf("\033[0m")
	fmt.Printf("\n")
}


func firstLine(){
	startColor()

	fmt.Print(HidariUe)
	for range make([]struct{}, Width-1){
		fmt.Print(Yoko+AidaUe)
	}
	fmt.Print(Yoko+MigiUe)
	endColor()
}

func middleLine(){
	for range make([]struct{}, Height-1){
		startColor()

		fmt.Print(AidaHidari)
		for range make([]struct{}, Width-1){
			fmt.Print(Yoko+Cross)
		}
		fmt.Print(Yoko+AidaMigi)

		endColor()
	}
}

func lastLine(){
	startColor()
	fmt.Print(HidariSita)
	for range make([]struct{}, Width-1){
		fmt.Print(Yoko+AidaSita)
	}
	fmt.Print(Yoko+MigiSita)
	endColor()
}


func main(){

	if len(os.Args) >1{
		var err error
		Size, err =strconv.Atoi(os.Args[1])
		if err !=nil{
			fmt.Fprintln(os.Stderr, err)
			os.Exit(1)
		}
	}

	Width=Size
	Height=Size

	firstLine()
	middleLine()
	lastLine()
}
