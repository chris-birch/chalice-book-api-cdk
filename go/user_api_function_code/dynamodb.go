package main

import (
	"context"
	"errors"
	"log"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/feature/dynamodb/attributevalue"
	"github.com/aws/aws-sdk-go-v2/feature/dynamodb/expression"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb/types"
)

var client *dynamodb.Client

func init() {
	cfg, err := config.LoadDefaultConfig(context.TODO())
	if err != nil {
		panic("configuration error, " + err.Error())
	}
	client = dynamodb.NewFromConfig(cfg)
}

// TableBasics encapsulates the Amazon DynamoDB service actions used in the examples.
// It contains a DynamoDB service client that is used to act on the specified table.
type TableBasics struct {
	DynamoDbClient *dynamodb.Client
	TableName      string
}

type Book struct {
	PK                      string  `dynamodbav:"pk"`
	BookID                  int     `dynamodbav:"book_id"`
	ISBN                    int     `dynamodbav:"isbn"`
	Authors                 string  `dynamodbav:"authors"`
	OriginalPublicationYear int     `dynamodbav:"original_publication_year"`
	Title                   string  `dynamodbav:"title"`
	LanguageCode            string  `dynamodbav:"language_code"`
	AverageRating           float32 `dynamodbav:"average_rating"`
}

// GetKey returns the composite primary key of the book in a format that can be
// sent to DynamoDB.
func (book Book) GetKey() map[string]types.AttributeValue {

	id, err := attributevalue.Marshal(book.BookID)
	if err != nil {
		panic(err)
	}
	return map[string]types.AttributeValue{"pk": id}
}

// GetBook gets book data from the DynamoDB table
func (basics TableBasics) GetBook(pk string) (Book, error) {
	book := Book{PK: pk}
	response, err := basics.DynamoDbClient.GetItem(context.TODO(), &dynamodb.GetItemInput{
		Key: book.GetKey(), TableName: aws.String(basics.TableName),
	})
	if err != nil {
		log.Printf("Couldn't get info about %v. Here's why: %v\n", book, err)
	} else {
		err = attributevalue.UnmarshalMap(response.Item, &book)
		if err != nil {
			log.Printf("Couldn't unmarshal response. Here's why: %v\n", err)
		}
	}
	return book, err
}

// GetBook gets book data from the DynamoDB table
func (basics TableBasics) Scan(bookId int) ([]Book, error) {
	var books []Book
	var err error
	var response *dynamodb.ScanOutput
	filtEx := expression.Name("book_id").Equal(expression.Value(bookId))
	expr, err := expression.NewBuilder().WithFilter(filtEx).Build()
	if err != nil {
		log.Printf("Couldn't build expressions for scan. Here's why: %v\n", err)
	} else {
		response, err = basics.DynamoDbClient.Scan(context.TODO(), &dynamodb.ScanInput{
			TableName:                 aws.String(basics.TableName),
			ExpressionAttributeNames:  expr.Names(),
			ExpressionAttributeValues: expr.Values(),
			FilterExpression:          expr.Filter(),
		})
		if err != nil {
			log.Printf("Couldn't find book with ID %v. Here's why: %v\n",
				bookId, err)
		} else {
			err = attributevalue.UnmarshalListOfMaps(response.Items, &books)
			if err != nil {
				log.Printf("Couldn't unmarshal query response. Here's why: %v\n", err)
			}
		}
	}
	return books, err
}

// TableExists determines whether a DynamoDB table exists.
func (basics TableBasics) TableExists() (bool, error) {
	exists := true
	_, err := basics.DynamoDbClient.DescribeTable(
		context.TODO(), &dynamodb.DescribeTableInput{TableName: aws.String(basics.TableName)},
	)
	if err != nil {
		var notFoundEx *types.ResourceNotFoundException
		if errors.As(err, &notFoundEx) {
			log.Printf("Table %v does not exist.\n", basics.TableName)
			err = nil
		} else {
			log.Printf("Couldn't determine existence of table %v. Here's why: %v\n", basics.TableName, err)
		}
		exists = false
	}
	return exists, err
}
