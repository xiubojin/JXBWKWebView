package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
)

type Person struct {
	Name string `json:"name"`
	Age  string `json:"age"`
	HTML string `json:"html"`
}

func main() {
	http.HandleFunc("/api/getperson", getPerson)
	http.Handle("/source/", http.StripPrefix("/source/", http.FileServer(http.Dir("source"))))
	err := http.ListenAndServe(":9090", nil)
	if err != nil {
		log.Fatal("ListenAndServer:", err)
	}
}

func getPerson(w http.ResponseWriter, r *http.Request) {
	p := Person{Name: "张三", Age: "12", HTML: htmlString()}
	jsons, _ := json.Marshal(p)
	w.Write([]byte(jsons))
}

func htmlString() string {
	b, err := ioutil.ReadFile("templdate.html")
	if err != nil {
		fmt.Print(err)
	}
	str := string(b)
	return str
}
