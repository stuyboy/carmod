package main

//A quick program to read through the .csv files and insert them into a Mysql database

import (
	"database/sql"
	"carmod/api/data"
	"carmod/api/model"
	"flag"
	"strings"
	"carmod/api/util"
)

var db *sql.DB

var fullArray []model.Part
var tireArray []model.Part
var rimsArray []model.Part
var partArray []model.Part

//Pointer to filesystem
var dir *string

const MAX_RESULTS int = 25;

func init() {
	db = data.DB()
}

func init() {
	dir = flag.String("resources", "../src/carmod/resources", "Resources Directory")
	flag.Parse()

	tireArray = createTireArray(*dir)
	rimsArray = createRimsArray(*dir)
	//partArray = createPartArray()

	fullArray = append(tireArray, rimsArray...)
}

func SearchParts(term string) []model.SearchResult {
	parts := []model.SearchResult{}
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

func main() {
	SaveDefaultParts(db)
}


func SaveParts(db *sql.DB, toSaveArray []model.Part) {
	for _, p := range toSaveArray {
		model.SavePart(db, &p)
	}
}

func SaveDefaultParts(db *sql.DB) {
	SaveParts(db, fullArray)
}

func createTireArray(dir string) []model.Part {
	return createArrayFromFile(
		dir + "/eBayMotors_US_TiresCatalog_20140418.csv",
		28,
		"Tires",
		0,
		2,
		9,
		12)
}

func createRimsArray(dir string) []model.Part {
	return createArrayFromFile(
		dir + "/eBayMotors_US_RimsCatalog_20110922.csv",
		15,
		"Rims",
		0,
		2,
		7,
		10)
}

func createPartArray(dir string) []model.Part {
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
	postarr := []model.Part{}
	dblarr := util.ReadCsvFile(filename, fields)

	for _, a := range dblarr {
		c := class
		i := a[idIdx]
		b := a[brandIdx]
		m := a[modelIdx]
		n := a[pCodeIdx]

		nmr := model.Part{Id: i, Classification: c, Brand: b, Model: m, ProductCode: n}
		nmr.SearchString = CreateSearchString(c + b + m + n)
		postarr = append(postarr, nmr)
	}
	return postarr
}


func CreateSearchString(s string) string {
	return strings.Replace(strings.ToLower(s), " ", "", -1)
}
