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

type ModResponse struct {
	Classification string
	Brand          string
	Model           string
	ProductCode     string
	SearchString   string
}

type SearchResponse struct {
	SearchTerm string
	Mods       []ModResponse
}

func hello(c web.C, w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello, %s!", c.URLParams["name"])
}

// search is the primary method to determine matches
func search(c web.C, w http.ResponseWriter, r *http.Request) {
	term := c.URLParams["phrase"]
	parts := []ModResponse{}

	for _, m := range nameresponse {
		ciName, ciTerm := m.SearchString, strings.ToLower(term)
		if strings.Contains(ciName, ciTerm) {
			parts = append(parts, m)
		}
	}

	sr := &SearchResponse{
		term,
		parts}

	jtxt, _ := json.Marshal(sr)
	fmt.Fprintf(w, string(jtxt))
}

// buildSearchStrings builds the searchable string that we use to match
func createMemoryArray(arr *[]ModResponse) []ModResponse {
	postarr := []ModResponse{}
	for _, m := range *arr {
		fullString := m.Brand + m.Model + m.ProductCode
		m.SearchString = strings.ToLower(fullString)
		postarr = append(postarr, m)
	}
	return postarr;
}

func createFileArray() []ModResponse {
	postarr := []ModResponse{}
	dblarr := etl.ReadCsvFile()

	for _, a := range dblarr {
		c := "Tires"
		b := a[2]
		m := a[9]
		n := a[12]

		nmr := ModResponse{Classification: c, Brand: b, Model: m, ProductCode: n}
		nmr.SearchString = strings.ToLower(c + b + m + n)
		postarr = append(postarr, nmr)
	}
	return postarr
}

func main() {
	//nameresponse = createMemoryArray(&nameresponse)
	nameresponse = createFileArray()

	goji.Get("/hello/:name", hello)
	goji.Get("/search/:phrase", search)
	goji.Serve()
}

var nameresponse = []ModResponse{
	{Classification: "Tires", Brand: "Bridgestone", Model: "Potenza", ProductCode: "RE050"},
	{Classification: "Tires", Brand: "Bridgestone", Model: "Turanza", ProductCode: "EL400"},
	{Classification: "Tires", Brand: "Bridgestone", Model: "Blizzak", ProductCode: "WS60"},
	{Classification: "Tires", Brand: "Bridgestone", Model: "Ecopia", ProductCode: "EP20"},
	{Classification: "Tires", Brand: "Goodyear", Model: "Eagle F1", ProductCode: "GS-2"},
	{Classification: "Tires", Brand: "Goodyear", Model: "Assurance"},
	{Classification: "Tires", Brand: "Goodyear", Model: "UltraGrip", ProductCode: "GW-3"},
	{Classification: "Tires", Brand: "Kumho", Model: "Ecsta", ProductCode: "4X"},
	{Classification: "Tires", Brand: "Kumho", Model: "Solus", ProductCode: "KR21"},
	{Classification: "Tires", Brand: "Pirelli", Model: "P Zero"},
	{Classification: "Tires", Brand: "Pirelli", Model: "P Zero Nero"},
	{Classification: "Tires", Brand: "Pirelli", Model: "P Zero Rosso"},
	{Classification: "Tires", Brand: "Pirelli", Model: "Cinturanto P7"},
	{Classification: "Tires", Brand: "Pirelli", Model: "Sottozero"},
	{Classification: "Tires", Brand: "Continental", Model: "ContiSportContact"},
	{Classification: "Tires", Brand: "Continental", Model: "ExtremeContact DWS"},
	{Classification: "Tires", Brand: "Continental", Model: "ContiPremiumContact"},
	{Classification: "Tires", Brand: "Continental", Model: "ProContact"}}
