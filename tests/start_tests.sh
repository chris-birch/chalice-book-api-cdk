printf '\nStarting tests...\n'
printf '\n## Create local-only AWS access enviroment variables ##\n\n'

export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
export AWS_DEFAULT_REGION=eu-west-2

# These are NOT real access keys!!! They're used for local Dynamodb access only.
# https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html#envvars-set

printf '\n## Start Dynamodb container ##\n\n'

docker compose up --detach

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

PYTEST_EXIT_CODE = $?

printf '\n## Stopping dynamodb container ##\n\n'

docker compose down

printf '\n## Remove local-only AWS access enviroment variables ##\n\n'

unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_DEFAULT_REGION

# The scipts exit code should equal pytest's
EXIT PYTEST_EXIT_CODE