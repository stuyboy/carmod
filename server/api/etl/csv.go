package etl

import (
	"encoding/csv"
	"fmt"
	"os"
)

func ReadCsvFile() [][]string {
	file, err := os.Open("resources/eBayMotors_US_TiresCatalog_20140418.csv")
	if err != nil {
		fmt.Println("Error:", err)
		return nil
	}

	defer file.Close()

	reader := csv.NewReader(file)
	reader.Comma = ','
	reader.LazyQuotes = true
	reader.FieldsPerRecord = 28

	records, err := reader.ReadAll()

	if err != nil {
		fmt.Println("Error read:", err)
		return nil
	}

	fmt.Println("Read %d records.", len(records))

	return records
}
