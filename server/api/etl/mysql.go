package etl

/* Collection of methods to query a MySQL database and return results */

import (
	"database/sql"
	_ "github.com/go-sql-driver/mysql"
	"log"
)

//Primary pointer for db connection
var db *sql.DB

type AutoResponse struct {
	Id			   	int32
	Year			int32
	Make			string
	Model           string
	Type			string
	Horsepower      int32
	Cylinders       int32
	Drive           string
}

func init() {
	ndb, err := sql.Open("mysql", "petrolhead:carmod@/carmod")

	if err != nil {
		panic(err.Error())
	}

	err = ndb.Ping()
	if err != nil {
		panic(err.Error())
	}

	db = ndb
}

func FindAuto(search string) []AutoResponse {
	postArr := []AutoResponse{}

	pctWrapSearch := "%" + search + "%"
	rows, err := db.Query("select make, model, type, drive, id, year, horsepower, cylinders from models where make like ? or model like ?", pctWrapSearch, pctWrapSearch)
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

		ar := AutoResponse{id, year, make, model, t, horsepower, cylinders, drive}
		postArr = append(postArr, ar)
	}
	return postArr
}
