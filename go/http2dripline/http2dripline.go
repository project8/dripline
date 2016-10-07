package main

import (
	"bytes"
    "fmt"
    "net/http"
)

func handler(w http.ResponseWriter, r *http.Request) {
	buf := new(bytes.Buffer)
	buf.ReadFrom(r.Body)
    //fmt.Fprintf(w, "Hi there, I love %s!", r.URL.Path[1:])
    fmt.Fprintf(w, "I received %s!", buf)
}

func RequestHandler(w http.ResponseWriter, r *http.Request) {
	buf := new(bytes.Buffer)
	buf.ReadFrom(r.Body)
	fmt.Fprintf(w, "Request received: %s", buf)
}

func AlertHandler(w http.ResponseWriter, r *http.Request) {
	buf := new(bytes.Buffer)
	buf.ReadFrom(r.Body)
	fmt.Fprintf(w, "Alert received: %s", buf)
}

func main() {
    http.HandleFunc("/request/", RequestHandler)
    http.HandleFunc("/alert/", AlertHandler)
    http.ListenAndServe(":8080", nil)
}
