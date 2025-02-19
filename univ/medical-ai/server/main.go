package main

import (
	"log"

	"github.com/gin-gonic/gin"
)



func startServer() error {
	r := gin.Default()
	r.POST("/schedule", scheduleEmail)

	// サーバ起動
	port := "8080"
	log.Printf("Server running on port %s...", port)
	if err := r.Run(":" + port); err != nil {
		return err
	}
	return nil
}

func main() {
	if err := startServer(); err != nil {
		log.Fatal(err)
	}
}

// func main() {
// 	sendMailTask(
// 		[]string{"https://docs.google.com/spreadsheets/d/1OUnzvpROWT8hL8nlc0vfXtQqTcLxty-5Lpd2kbFkCwQ/edit?gid=1075438636#gid=1075438636"},
// 	)()
// }

// func main() {
// 	mail := sendmail.Mail{
// 		User:      "hayao",
// 		Domain:    "mg.hayao0819.com",
// 		Subject:   "test",
// 		Body:      "test",
// 		To:        []string{"shun819.mail@gmail.com"},
// 	}
// 	if err := mail.Send(); err != nil {
// 		log.Fatal(err)
// 	}
// }

// func main() {
// 	_, err := ns.NewJob(
// 		gocron.OneTimeJob(gocron.OneTimeJobStartDateTime(time.Now().Add(time.Second*5))),
// 		gocron.NewTask(func() {
// 			fmt.Println("Hello, world!")
// 		}),
// 	)
// 	if err != nil {
// 		log.Fatalln(err)
// 	}
// 	http.ListenAndServe(":8080", nil)
// }
