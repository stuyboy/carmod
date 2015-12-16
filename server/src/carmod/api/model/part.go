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
	SearchString   string `json:"searchString"`
}

func (c Part) Name() string {
	return "Part"
}

func SearchParts(db *sql.DB, search string) []SearchResult {
	postArr := []SearchResult{}

	sqlPhrase := `select id, classification, brand, model, productCode from parts_unique where
				  match (classification, brand, model) against (? in boolean mode)`

	individualTerms := strings.Fields(search)

	argPhrase := ""
	for _, term := range individualTerms {
		argPhrase += "+" + term + "* "
	}

	rows, err := db.Query(sqlPhrase, argPhrase)

	if err != nil {
		panic(err.Error())
	}

	defer rows.Close()
	for rows.Next() {
		var id, classification, brand, model, productCode string

		err := rows.Scan(&id, &classification, &brand, &model, &productCode)
		if (err != nil) {
			log.Fatal(err)
		}

		ar := Part{Id: id, Classification: classification, Brand: brand, Model: model, ProductCode: productCode}
		postArr = append(postArr, ar)
	}
	return postArr
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

