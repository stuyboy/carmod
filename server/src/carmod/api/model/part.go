package model

import (
	"strings"

	"database/sql"
	"log"
	"github.com/go-sql-driver/mysql"
)

//When searching for anything, how items are returned
type Part struct {
	Id			   string `json:"id"`
	Classification string `json:"classification"`
	Brand          string `json:"brand"`
	Model          string `json:"model"`
	ProductCode    string `json:"productCode"`
	ImageUrl       string `json:"imageUrl"`
	SearchString   string `json:"searchString"`
}

func (c Part) Name() string {
	return "Part"
}

/**
 Return a random image url to help rendering
 */
func samplePartImage(partIdx int) string {
	samplePartImages := [10]string {
		"performance-brake-kits_ic_5.jpg",
		"wheels-and-rims_ic_5.jpg",
		"exhaust-parts_ic_5.jpg",
		"tail-lights_ic_5.jpg",
		"suspension-parts_ic_5.jpg",
		"charging-starting_ic_5.jpg",
		"air-intakes_ic_5.jpg",
		"performance-chips_ic_5.jpg",
		"sear-covers_ic_5.jpg",
		"chrome-accessories_ic_5.jpg"}

	return "http://www.carid.com/ic/icons/" + samplePartImages[partIdx % len(samplePartImages)]
}

func SearchParts(db *sql.DB, search string) []SearchResult {
	sqlPhrase := `select id, classification, brand, model, productCode from parts_unique where
				  match (classification, brand, model) against (? in boolean mode) limit 100`

	individualTerms := strings.Fields(search)

	argPhrase := ""
	for _, term := range individualTerms {
		argPhrase += "+" + term + "* "
	}

	rows, err := db.Query(sqlPhrase, argPhrase)

	if err != nil {
		panic(err.Error())
	}

	return partFromDbRow(rows);
}

//Save a custom part into the database
func SavePart(db *sql.DB, newPart *Part) sql.Result {
	result, err := db.Exec(
		"INSERT into parts (classification, brand, model, productCode) values (?, ?, ?, ?)",
		newPart.Classification,
		newPart.Brand,
		newPart.Model,
		newPart.ProductCode)

	if err != nil {
		if mysqlError, ok := err.(*mysql.MySQLError); ok {
			if mysqlError.Number == 1062 {
				log.Println("Part already added: " + err.Error())
			} else {
				log.Println(err.Error())
			}
		}
	}

	return result
}

func RecentParts(db *sql.DB, limit int8) []SearchResult {
	sqlPhrase := `select id, classification, brand, model, productCode from parts_unique order by createdAt desc limit ?`

	rows, err := db.Query(sqlPhrase, limit)

	if err != nil {
		panic(err.Error())
	}

	return partFromDbRow(rows);
}

func partFromDbRow(rows *sql.Rows) []SearchResult {
	postArr := []SearchResult{}

	count := 0
	defer rows.Close()
	for rows.Next() {
		var id, classification, brand, model, productCode string

		err := rows.Scan(&id, &classification, &brand, &model, &productCode)
		if (err != nil) {
			log.Fatal(err)
		}

		ar := Part{Id: id, Classification: classification, Brand: brand, Model: model, ProductCode: productCode}
		ar.ImageUrl = samplePartImage(count)
		postArr = append(postArr, ar)
		count++
	}

	return postArr;
}

