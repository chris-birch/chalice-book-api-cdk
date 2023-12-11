require (
	github.com/aws/aws-lambda-go v1.36.1
	github.com/aws/aws-sdk-go-v2 v1.22.1
	github.com/aws/aws-sdk-go-v2/config v1.19.1
	github.com/aws/aws-sdk-go-v2/feature/dynamodb/attributevalue v1.12.0
	github.com/aws/aws-sdk-go-v2/feature/dynamodb/expression v1.6.0
	github.com/aws/aws-sdk-go-v2/service/dynamodb v1.25.0
	github.com/aws/aws-sdk-go-v2/service/s3 v1.42.0
)

replace gopkg.in/yaml.v2 => gopkg.in/yaml.v2 v2.2.8

module hello-world

go 1.16
