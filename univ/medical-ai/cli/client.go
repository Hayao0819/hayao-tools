package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"time"
)

type FormNotifyClient struct {
	Server string
}

func NewFormNotifyClient(server string) FormNotifyClient {
	return FormNotifyClient{
		Server: server,
	}
}

func (c FormNotifyClient) sendRequest(method string, path string, body []byte) ([]byte, error) {
	u, err := url.JoinPath(c.Server, path)
	if err != nil {
		return nil, err
	}

	// send request
	hc := http.DefaultClient
	bdReader := bytes.NewBuffer(body)
	req, err := http.NewRequest(method, u, bdReader)
	if err != nil {
		return nil, err
	}

	resp, err := hc.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	resBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	return resBody, nil
}

type NotifyRequest struct {
	SendTo         string   `json:"send_to"`
	DateTime       string   `json:"datetime"`
	SpreadsheetURL []string `json:"spreadsheet_url"`
}

func (c *FormNotifyClient) Notify(date time.Time, sheets []string, to string) error {
	req := NotifyRequest{
		SendTo:         to,
		DateTime:       date.Format(time.RFC3339),
		SpreadsheetURL: sheets,
	}

	jsonBody, err := json.Marshal(req)
	if err != nil {
		return err
	}

	resBody, err := c.sendRequest(http.MethodPost, "/schedule", jsonBody)
	if err != nil {
		return err
	}

	fmt.Println(string(resBody))
	return nil
}
