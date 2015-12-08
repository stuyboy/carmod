package model

import (
	"database/sql"
	"log"
	"strings"
)

type Car struct {
	Id			   	int32  `json:"id"`
	Year			int32  `json:"year"`
	Make			string `json:"make"`
	Model           string `json:"model"`
	Type			string `json:"type"`
	Horsepower      int32  `json:"horsepower"`
	Cylinders       int32  `json:"cylinders"`
	Drive           string `json:"drive"`
}

func (c Car) Name() string {
	return "Car"
}

func SearchCars(db *sql.DB, search string) []SearchResult {
	postArr := []SearchResult{}

	fullSqlPhrase := ""
	individualTerms := strings.Fields(search)
	var sqlArgs []interface{}

	for _, term := range individualTerms {
		if fullSqlPhrase != "" {
			fullSqlPhrase += " and "
		}

		pctWrapSearch := "%" + term + "%"
		fullSqlPhrase += "(make like ? or model like ?)"
		sqlArgs = append(sqlArgs, pctWrapSearch)
		sqlArgs = append(sqlArgs, pctWrapSearch)
	}

	//log.Println(fullSqlPhrase)
	//log.Println(sqlArgs)

	rows, err := db.Query("select make, model, type, drive, id, year, horsepower, cylinders from models where " + fullSqlPhrase, sqlArgs...)
	//rows, err := db.Query("select make, model, type, drive, id, year, horsepower, cylinders from models limit 1")

	if err != nil {
		panic(err.Error())
	}

	defer rows.Close()
	for rows.Next() {
		var make, model, t, drive string
		var id, year, horsepower, cylinders int32

		err := rows.Scan(&make, &model, &t, &drive, &id, &year, &horsepower, &cylinders)
		if (err != nil) {
			log.Fatal(err)
		}

		ar := Car{id, year, make, model, t, horsepower, cylinders, drive}
		postArr = append(postArr, ar)
	}
	return postArr
}
