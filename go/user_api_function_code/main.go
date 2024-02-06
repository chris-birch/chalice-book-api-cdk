package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
	"strconv"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

var TableName string = os.Getenv("TABLENAME")

// Scan Dynamodb and return a list of all books found
func GetBooks(bookId int) ([]Book, error) {
	RequestedBook := Book{book_id: bookId}
	return (TableBasics.Scan(TableBasics{TableName: TableName, DynamoDbClient: client}, RequestedBook.book_id))
}

// Error Handler - Client
func clientError(status int) (events.APIGatewayProxyResponse, error) {

	return events.APIGatewayProxyResponse{
		Body:       http.StatusText(status),
		StatusCode: status,
	}, nil
}

// Error Handler - Server
func serverError(err error) (events.APIGatewayProxyResponse, error) {
	log.Println(err.Error())

	return events.APIGatewayProxyResponse{
		Body:       http.StatusText(http.StatusInternalServerError),
		StatusCode: http.StatusInternalServerError,
	}, nil
}

// Lambda Handler
func handler(request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	// Convert request path 'string' to int
	i, err := strconv.Atoi(request.PathParameters["book_id"])
	if err != nil {
		serverError(err)
	}

	// Get books from db
	bklist, err := GetBooks(int(i))
	if err != nil {
		return serverError(err)
	}

	// Check how many books were returned, there should only be 1
	if len(bklist) == 0 {
		return clientError(http.StatusNotFound)
	} else if len(bklist) > 1 {
		log.Printf("Error: When scanning for book with ID %v, we found more than 1 book.\n", i)
		return clientError(http.StatusBadRequest)
	}

	// Marshal book to JSON
	json, err := json.Marshal(bklist)
	if err != nil {
		return serverError(err)
	}

	// Return the book
	return events.APIGatewayProxyResponse{
		Body:       string(json),
		StatusCode: 200,
	}, nil

}

func main() {
	lambda.Start(handler)
}
