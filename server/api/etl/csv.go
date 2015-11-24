package etl

import (
	"encoding/csv"
	"fmt"
	"os"
)

func ReadCsvFile(filename string, fieldsPerRecord int) [][]string {
	file, err := os.Open(filename)
	if err != nil {
		fmt.Println("Error:", err)
		return nil
	}

	defer file.Close()

	reader := csv.NewReader(file)
	reader.Comma = ','
	reader.LazyQuotes = true
	reader.FieldsPerRecord = fieldsPerRecord

	records, err := reader.ReadAll()

	if err != nil {
		fmt.Println("Error read:", err)
		return nil
	}

	fmt.Println("Read %d records.", len(records))

	return records
}
