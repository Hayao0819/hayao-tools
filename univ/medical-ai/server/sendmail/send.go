package sendmail

import (
	"context"
	"fmt"
	"time"

	"github.com/mailgun/mailgun-go/v4"
)

var accessToken string
var domain string

type Mail struct {
	Sender    string
	Subject   string
	Body      string
	Recipient string
}

func (m *Mail) Send() error {
	// Create an instance of the Mailgun Client
	mg := mailgun.NewMailgun(domain, accessToken)

	//When you have an EU-domain, you must specify the endpoint:
	// mg.SetAPIBase("https://api.eu.mailgun.net/v3")

	message := mailgun.NewMessage(m.Sender, m.Subject, m.Body, m.Recipient)

	ctx, cancel := context.WithTimeout(context.Background(), time.Second*10)
	defer cancel()

	// Send the message with a 10-second timeout
	resp, id, err := mg.Send(ctx, message)
	if err != nil {
		return err
	}

	fmt.Printf("ID: %s Resp: %s\n", id, resp)
	return nil
}
