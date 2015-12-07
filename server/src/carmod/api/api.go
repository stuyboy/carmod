package main

import (
	"fmt"
	"net/http"

	"github.com/zenazn/goji"
	"github.com/zenazn/goji/web"

	"encoding/json"

	"carmod/api/model"
	"carmod/api/data"

	"database/sql"
)

//Pointer to database
var db *sql.DB

func init() {
	db = data.DB()
}

func hello(c web.C, w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello, %s!", c.URLParams["name"])
}

// search for cars
func autoSearch(c web.C, w http.ResponseWriter, r *http.Request) {
	term := c.URLParams["phrase"]
	cars := model.SearchCars(db, term)

	sr := &model.SearchResponse{
		term,
		cars}

	jtxt, _ := json.Marshal(sr)
	fmt.Fprintf(w, string(jtxt))
}

// search is the primary method to determine matches
func partSearch(c web.C, w http.ResponseWriter, r *http.Request) {
	term := c.URLParams["phrase"]
	parts := model.SearchParts(term)

	sr := &model.SearchResponse{
		term,
		parts}

	jtxt, _ := json.Marshal(sr)
	fmt.Fprintf(w, string(jtxt))
}

func main() {
	goji.Get("/hello/:name", hello)
	goji.Get("/search/:phrase", partSearch)
	goji.Get("/auto/:phrase", autoSearch)
	goji.Serve()
}