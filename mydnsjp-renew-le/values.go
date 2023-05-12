package main

import "net/http"

var environ = struct {
	Domain string `env:"CERTBOT_DOMAIN"`
	Validation string `env:"CERTBOT_VALIDATION"`
	//Token string `env:"CERTBOT_TOKEN"`
	//CertPath string `env:"CERTBOT_CERT_PATH"`
	//KeyPath string `env:"CERTBOT_KEY_PATH"`
	//SniDomain string `env:"CERTBOT_SNI_DOMAIN"`
	//AuthOutput string `env:"CERTBOT_AUTH_OUTPUT"`
}{}

type mode int

const (
	none mode = iota
	regist
	delete
	simulation
)

var current_mode mode = none

var request *http.Request = nil
