package sendmail

import (
	"context"
	"fmt"
	"os"
	"time"

	"github.com/mailgun/mailgun-go/v4"
)

var accessToken string = os.Getenv("MAILGUN_TOKEN")

const domain string = "mg.hayao0819.com"

type Mail struct {
	Domain  string
	User    string
	Subject string
	Body    string
	To      []string
}

func (m *Mail) Send() error {

	// fmt.Println(accessToken)

	// Create an instance of the Mailgun Client
	mg := mailgun.NewMailgun(domain, accessToken)

	//When you have an EU-domain, you must specify the endpoint:
	// mg.SetAPIBase("https://api.eu.mailgun.net/v3")

	sender := fmt.Sprintf("%s@%s", m.User, domain)
	message := mailgun.NewMessage(sender, m.Subject, m.Body, m.To...)

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
