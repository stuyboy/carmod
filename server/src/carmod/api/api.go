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

func extractPart(c web.C, w http.ResponseWriter, r *http.Request) {
	//url := c.URLParams["url"]

	url := r.URL.Query().Get("url")
	log.Println("Trying to parse " + url)

	product := data.ExtractProduct(url)
	//product := data.ExtractProduct("https://deutscheautoparts.com/make-model-year/audi/a4/b7-2005-2008/8e0-121-403.html")
	//product := data.ExtractProduct(`http://www.uspmotorsports.com/Engine/Software/Eurodyne-MK7-GTI-Reflash-with-Flash-Tool.html?gdftrk=gdfV210471_a_7c4200_a_7c11544_a_7cSKU4641&gclid=Cj0KEQiAnJqzBRCW0rGWnKnckOIBEiQA6qDBarUDXx6D-wqivYuGs9TsBwSbIqtyM_ZO5oMvpSUb2EcaAtPU8P8HAQ`)
	//product := data.ExtractProduct(`http://blog.diffbot.com/diffbots-new-product-api-teaches-robots-to-shop-online/`)

	log.Println("I think I am here")

	//fmt.Fprintf(w, "hello world.")
	jtxt, _ := json.Marshal(product)
	fmt.Fprintf(w, string(jtxt))
	//fmt.Println(product.String())
	//log.Println(product)
}

func main() {
	goji.Get("/hello/:name", hello)
	goji.Get("/search/:phrase", partSearch)
	goji.Get("/auto/:phrase", autoSearch)
	goji.Get("/extract", extractPart)
	goji.Serve()
}