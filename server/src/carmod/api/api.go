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
	"log"
	"strconv"
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
	outputJson(w, jtxt)
}

func partSearch(c web.C, w http.ResponseWriter, r *http.Request) {
	term := c.URLParams["phrase"]
	parts := model.SearchParts(db, term)

	sr := & model.SearchResponse{
		term,
		parts}

	jtxt, _ := json.Marshal(sr)
	outputJson(w, jtxt)
}

func partRecents(c web.C, w http.ResponseWriter, r *http.Request) {
	parts := model.RecentParts(db, 10)

	sr := & model.SearchResponse {
		"latest",
		parts }

	jtxt, _ := json.Marshal(sr)
	outputJson(w, jtxt)
}

// given a product url, pull out the part and save it into the database?
func extractPart(c web.C, w http.ResponseWriter, r *http.Request) {
	url := r.URL.Query().Get("url")
	toSave, _ := strconv.ParseBool(r.URL.Query().Get("save"))

	if url != "" {
		product := data.ExtractProduct(url)
		if product != nil {
			part := data.ProductToPart(product)

			if toSave && part != nil {
				model.SavePart(db, part)
			}

			jtxt, _ := json.Marshal(part)
			outputJson(w, jtxt)
		}
	}

	log.Println("No url found for extraction.")
}

func outputJson(w http.ResponseWriter, arr []byte) {
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")
	fmt.Fprintf(w, string(arr))
}

func main() {
	goji.Get("/hello/:name", hello)
	goji.Get("/search/:phrase", partSearch)
	goji.Get("/parts/latest", partRecents)
	goji.Get("/auto/:phrase", autoSearch)
	goji.Get("/extract", extractPart)
	goji.Serve()
}