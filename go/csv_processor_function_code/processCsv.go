package main

import (
	"bytes"
	"encoding/csv"
	"encoding/json"
	"log"
	"os"
	"strconv"
)

type Book struct {
	Book_id                 int     `json:"book_id"`
	Isbn                    int     `json:"isbn"`
	Authors                 string  `json:"authors"`
	OriginalPublicationYear int     `json:"original_publication_year"`
	Title                   string  `json:"title"`
	LanguageCode            string  `json:"language_code"`
	AverageRating           float32 `json:"average_rating"`
}

func stringToInt(val string, line int) int {
	line = line + 1
	newint, err := strconv.Atoi(val)
	if err != nil {
		log.Printf("Error on row %v: '%v'\n", line, err)
		os.Exit(1)
	}
	return newint
}

func stringToFloat(val string, line int) float64 {
	line = line + 1
	newint, err := strconv.ParseFloat(val, 32)
	if err != nil {
		log.Printf("Error on row %v: '%v'\n", line, err)
		os.Exit(1)
	}
	return newint
}

func compareCsvHeaders(a, b []string) bool {
	if len(a) != len(b) {
		return false
	}
	for i := range a {
		if a[i] != b[i] {
			return false
		}
	}
	return true
}

// convert csv lines to array of structs
func createBookList(data [][]string) []Book {
	var bookList []Book
	csvHeaders := []string{"book_id", "isbn", "authors", "original_publication_year", "title", "language_code", "average_rating"}
	for i, line := range data {
		// Check that the CSV headers are correct
		if i == 0 {
			if !compareCsvHeaders(line, csvHeaders) {
				log.Printf("Invalid CSV headers:\n Expected: %q\n Received: %q", csvHeaders, line)
				break
			}
		}
		// Continue processing
		if i > 0 {
			var bk Book
			for j, field := range line {
				switch j {
				case 0:
					bk.Book_id = stringToInt(field, i)
				case 1:
					bk.Isbn = stringToInt(field, i)
				case 2:
					bk.Authors = field
				case 3:
					bk.OriginalPublicationYear = int(stringToFloat(field, i))
				case 4:
					bk.Title = field
				case 5:
					bk.LanguageCode = field
				case 6:
					bk.AverageRating = float32(stringToFloat(field, i))
				}
			}
			bookList = append(bookList, bk)
		}

	}
	return bookList
}

func GetJsonFromCsv(filedata []byte) []byte {

	// Read CSV file using csv.Reader
	csvReader := csv.NewReader(bytes.NewBuffer(filedata))
	data, err := csvReader.ReadAll()
	if err != nil {
		log.Fatal(err)
	}

	// Assign successive lines of raw CSV data to fields of the created structs
	bookList := createBookList(data)

	// Convert an array of structs to JSON using marshaling functions from the encoding/json package
	jsonData, err := json.MarshalIndent(bookList, "", "  ")
	if err != nil {
		log.Fatal(err)
	}

	return jsonData
}
