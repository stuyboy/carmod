package model

import (
	"strings"

	"carmod/api/util"
	"flag"
)

var fullArray []Part
var tireArray []Part
var rimsArray []Part
var partArray []Part

//Pointer to filesystem
var dir *string

const MAX_RESULTS int = 25;

//When searching for anything, how items are returned
type Part struct {
	Id			   string `json:"id"`
	Classification string `json:"classification"`
	Brand          string `json:"brand"`
	Model          string `json:"model"`
	ProductCode    string `json:"productCode"`
	SearchString   string `json:"searchString"`
}

func (c Part) Name() string {
	return "Part"
}

func init() {
	dir = flag.String("resources", "../src/carmod/resources", "Resources Directory")
	flag.Parse()

	tireArray = createTireArray(*dir)
	rimsArray = createRimsArray(*dir)
	//partArray = createPartArray()

	fullArray = append(tireArray, rimsArray...)
}

func SearchParts(term string) []SearchResult {
	parts := []SearchResult{}
	searchArray := fullArray

	for _, m := range searchArray {
		ciName, ciTerm := m.SearchString, CreateSearchString(term)
		if strings.Contains(ciName, ciTerm) {
			parts = append(parts, m)
		}
		if len(parts) > MAX_RESULTS {
			break
		}
	}

	return parts
}

func createTireArray(dir string) []Part {
	return createArrayFromFile(
		dir + "/eBayMotors_US_TiresCatalog_20140418.csv",
		28,
		"Tires",
		0,
		2,
		9,
		12)
}

func createRimsArray(dir string) []Part {
	return createArrayFromFile(
		dir + "/eBayMotors_US_RimsCatalog_20110922.csv",
		15,
		"Rims",
		0,
		2,
		7,
		10)
}

func createPartArray(dir string) []Part {
	return createArrayFromFile(
		dir + "/US_Parts_Catalog20151029.csv",
		8,
		"Parts",
		0,
		2,
		4,
		3)
}

func createArrayFromFile(filename string, fields int, class string, idIdx int, brandIdx int, modelIdx int, pCodeIdx int) []Part {
	postarr := []Part{}
	dblarr := util.ReadCsvFile(filename, fields)

	for _, a := range dblarr {
		c := class
		i := a[idIdx]
		b := a[brandIdx]
		m := a[modelIdx]
		n := a[pCodeIdx]

		nmr := Part{Id: i, Classification: c, Brand: b, Model: m, ProductCode: n}
		nmr.SearchString = CreateSearchString(c + b + m + n)
		postarr = append(postarr, nmr)
	}
	return postarr
}


func CreateSearchString(s string) string {
	return strings.Replace(strings.ToLower(s), " ", "", -1)
}
