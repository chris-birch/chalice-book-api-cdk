printf '\nStarting tests...\n'
printf '\n## Start Dynamodb container ##\n\n'

docker-compose up --detach

printf '\n## Create Dynamodb Table ##\n\n'

aws dynamodb create-table \
    --table-name Books \
    --endpoint-url http://localhost:8000 \
    --billing-mode PAY_PER_REQUEST \
    --attribute-definitions '{ 
                                "AttributeName": "pk",
                                "AttributeType": "S"
                            }' \
    --key-schema '{ 
                    "AttributeName": "pk",
                    "KeyType": "HASH"
                }'

printf '\n## Loading table data ##\n\n'

aws dynamodb batch-write-item \
    --request-items file://request-items.json \
    --endpoint-url http://localhost:8000 \

printf '\n## Starting pytest ##\n\n'

poetry run pytest -v -W ignore::UserWarning

printf '\n## Stopping dynamodb container ##\n\n'

docker compose down