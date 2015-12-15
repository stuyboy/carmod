package data

/* Collection of methods to query a MySQL database and return results */

import (
	"database/sql"
	_ "github.com/go-sql-driver/mysql"
)

//Primary pointer for db connection
var db *sql.DB

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

func DB() *sql.DB {
	return db
}


