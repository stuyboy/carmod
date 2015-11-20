package main

import (
	"fmt"
	"net/http"

	"github.com/zenazn/goji"
	"github.com/zenazn/goji/web"

	"encoding/json"

	"strings"
)

type ModResponse struct {
	Classification string
	Name string
}

type SearchResponse struct {
	SearchTerm string
	Mods []ModResponse
}

func hello(c web.C, w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello, %s!", c.URLParams["name"])
}

func search(c web.C, w http.ResponseWriter, r *http.Request) {
	term := c.URLParams["phrase"]
	parts := []ModResponse {}

	for _, m := range typeresponse {
		ciName, ciTerm := strings.ToLower(m.Name), strings.ToLower(term)
		if strings.Contains(ciName, ciTerm) {
			parts = append(parts, m)
		}
	}

	sr := &SearchResponse{
		term,
		parts}

	jtxt,_ := json.Marshal(sr)
	fmt.Fprintf(w, string(jtxt))
}

func main() {
	goji.Get("/hello/:name", hello)
	goji.Get("/search/:phrase", search)
	goji.Serve()
}

var typeresponse = []ModResponse{
	{ Classification: "Tires", Name: "Tires" },
	{ Classification: "Rims", Name: "Rims" },
	{ Classification: "Windshield", Name: "Windshield" },
	{ Classification: "Stickers", Name: "Stickers" },
	{ Classification: "Exhaust", Name: "Exhaust" },
	{ Classification: "Engine", Name: "Engine" },
	{ Classification: "Interior", Name: "Interior" },
	{ Classification: "Exterior", Name: "Exterior" }}

var nameresponse = []ModResponse{
	{ Classification: "Tires", Name: "Bridgestone" },
	{ Classification: "Tires", Name: "Goodyear" },
	{ Classification: "Tires", Name: "Kumho" },
	{ Classification: "Tires", Name: "Pirelli" },
	{ Classification: "Tires", Name: "Continental" },
	{ Classification: "Tires", Name: "Generic" }}

