package main

import (
	"bytes"
	"context"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/s3"
)

var ApiUrl string = os.Getenv("APIURL")

// DownloadFile gets an object from a bucket and stores it in a local file.
func GetFileContents(ctx context.Context, bucketName string, objectKey string) ([]byte, error) {
	sdkConfig, err := config.LoadDefaultConfig(ctx)
	if err != nil {
		log.Printf("failed to load default config: %s", err)
		return nil, err
	}
	s3Client := s3.NewFromConfig(sdkConfig)

	result, err := s3Client.GetObject(context.TODO(), &s3.GetObjectInput{
		Bucket: aws.String(bucketName),
		Key:    aws.String(objectKey),
	})
	if err != nil {
		log.Printf("Couldn't get object %v:%v. Here's why: %v\n", bucketName, objectKey, err)
		return nil, err
	}
	defer result.Body.Close()

	body, err := io.ReadAll(result.Body)
	if err != nil {
		log.Printf("Couldn't read object body from %v. Here's why: %v\n", objectKey, err)
	}
	return body, err
}

func postToApi(json []byte) {
	url := ApiUrl

	// The API requires the book list to be in a JSON "data" object
	newBody := "{\"data\":" + string(json) + "}"

	// Send request to API
	req, err := http.NewRequest("POST", url, bytes.NewBuffer([]byte(newBody)))
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		panic(err)
	}
	defer resp.Body.Close()

	fmt.Println("response Status:", resp.Status)
	body, _ := io.ReadAll(resp.Body)
	fmt.Println("response Body:", string(body))
}

// Lambda function handler
func handler(ctx context.Context, s3Event events.S3Event) error {
	sdkConfig, err := config.LoadDefaultConfig(ctx)
	if err != nil {
		log.Printf("failed to load default config: %s", err)
		return err
	}
	s3Client := s3.NewFromConfig(sdkConfig)

	for _, record := range s3Event.Records {
		bucket := record.S3.Bucket.Name
		key := record.S3.Object.URLDecodedKey
		headOutput, err := s3Client.HeadObject(ctx, &s3.HeadObjectInput{
			Bucket: &bucket,
			Key:    &key,
		})
		if err != nil {
			log.Printf("error getting head of object %s/%s: %s", bucket, key, err)
			return err
		}
		log.Printf("successfully retrieved %s/%s of type %s", bucket, key, *headOutput.ContentType)

		if *headOutput.ContentType == "text/csv" {
			// Get the file contents
			fileContents, err := GetFileContents(ctx, bucket, key)
			if err != nil {
				log.Printf("Unable to get file contents: %v", err)
				return err
			}
			// Get the processed JSON object
			jsonData := GetJsonFromCsv(fileContents)

			// POST the jason data to the API
			postToApi(jsonData)
		}
	}

	return nil
}

func main() {
	lambda.Start(handler)
}
