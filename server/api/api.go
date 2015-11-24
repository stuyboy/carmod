package main

import (
	"fmt"
	"net/http"

	"github.com/zenazn/goji"
	"github.com/zenazn/goji/web"

	"encoding/json"

	"strings"

	"carmod/server/api/etl"
)

const MAX_RESULTS int = 25;

var fullArray []ModResponse
var tireArray []ModResponse
var rimsArray []ModResponse
var partArray []ModResponse

//When searching for anything, how items are returned
type ModResponse struct {
	Id			   string
	Classification string
	Brand          string
	Model          string
	ProductCode    string
	SearchString   string
}

//The full response.  What search term was, and what was matched.
type SearchResponse struct {
	SearchTerm string
	Mods       []ModResponse
}

func hello(c web.C, w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello, %s!", c.URLParams["name"])
}

func createSearchString(s string) string {
	return strings.Replace(strings.ToLower(s), " ", "", -1)
}

// search is the primary method to determine matches
func search(c web.C, w http.ResponseWriter, r *http.Request) {
	term := c.URLParams["phrase"]
	parts := []ModResponse{}

	searchArray := fullArray

	for _, m := range searchArray {
		ciName, ciTerm := m.SearchString, createSearchString(term)
		if strings.Contains(ciName, ciTerm) {
			parts = append(parts, m)
		}
		if len(parts) > MAX_RESULTS {
			break
		}
	}

	sr := &SearchResponse{
		term,
		parts}

	jtxt, _ := json.Marshal(sr)
	fmt.Fprintf(w, string(jtxt))
}

func createTireArray() []ModResponse {
	return createArrayFromFile(
		"resources/eBayMotors_US_TiresCatalog_20140418.csv",
		28,
		"Tires",
		0,
		2,
		7,
		10)
}

func createRimsArray() []ModResponse {
	return createArrayFromFile(
		"resources/eBayMotors_US_RimsCatalog_20110922.csv",
		15,
		"Rims",
		0,
		2,
		7,
		10)
}

func createPartArray() []ModResponse {
	return createArrayFromFile(
		"resources/US_Parts_Catalog20151029.csv",
		8,
		"Parts",
		0,
		2,
		4,
		3)
}

func createArrayFromFile(filename string, fields int, class string, idIdx int, brandIdx int, modelIdx int, pCodeIdx int) []ModResponse {
	postarr := []ModResponse{}
	dblarr := etl.ReadCsvFile(filename, fields)

	for _, a := range dblarr {
		c := class
		i := a[idIdx]
		b := a[brandIdx]
		m := a[modelIdx]
		n := a[pCodeIdx]

		nmr := ModResponse{Id: i, Classification: c, Brand: b, Model: m, ProductCode: n}
		nmr.SearchString = createSearchString(c + b + m + n)
		postarr = append(postarr, nmr)
	}
	return postarr
}

func main() {
	tireArray = createTireArray()
	rimsArray = createRimsArray()
	//partArray = createPartArray()

	fullArray = append(tireArray, rimsArray...)

	goji.Get("/hello/:name", hello)
	goji.Get("/search/:phrase", search)
	goji.Serve()
}