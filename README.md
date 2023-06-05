# Book Management API

An AWS hosted RESTful API for data transfer with a web front-end for management and a database for storage utilizing [serverless](https://www.redhat.com/en/topics/cloud-native-apps/what-is-serverless "https://www.redhat.com/en/topics/cloud-native-apps/what-is-serverless") architecture.

Using the [Chalice](https://aws.github.io/chalice/ "https://aws.github.io/chalice/") framework to deploy most of the architecture and [AWS Cloud Development Kit (AWS CDK)](https://docs.aws.amazon.com/cdk/v2/guide/home.html "https://docs.aws.amazon.com/cdk/v2/guide/home.html") to deploy the remaining (serverless) components. The web management console and user authentication is deployed using [AWS Amplify](https://aws.amazon.com/amplify/ "https://aws.amazon.com/amplify/").

## Architecture 

![Markdown API Architecture](https://github.com/chris-birch/chalice-book-api-cdk/assets/21064947/02151ed6-0b4b-4f6e-a4a7-d2a59136ab07)


# Quick Start
## Requirements
### Poetry
Poetry is a tool for **dependency management** and **packaging** in Python.

See the [Installation](https://python-poetry.org/docs/#installation) guide for more information.

``` bash
curl -sSL https://install.python-poetry.org | python3 -
```

Poetry requires **Python 3.7+**

### AWS CLI
The AWS Command Line Interface (AWS CLI) is an open source tool that enables you to interact with AWS services using commands in your command-line shell.

[Installing or updating the latest version of the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html#getting-started-install-instructions)

### AWS CDK
The **AWS Cloud Development Kit (AWS CDK)** is an open-source software development framework to define cloud infrastructure in code and provision it through AWS CloudFormation.

See [Getting Started](https://docs.aws.amazon.com/cdk/latest/guide/getting_started.html) with the AWS CDK guide for more details.

``` bash
npm install -g aws-cdk
```

The CDK requires [Node.js and npm](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm) to run.

I recommend you use [Node Version Manager](https://github.com/nvm-sh/nvm#installing-and-updating) and Node version **v18.16.0 (Latest LTS: Hydrogen)**
``` bash
nvm install --lts
```

### pyenv (optional)
Use [pyenv](https://github.com/pyenv/pyenv#readme) to manage per project python versions.

installing with [Homebrew](https://brew.sh):
```bash
brew update
brew install pyenv
```
Other Linux versions:
``` bash
curl https://pyenv.run | bash
```

*Complete the shell / environment setup steps as per the pyenv documentation*
*Complete the [Suggested build environment](https://github.com/pyenv/pyenv/wiki#suggested-build-environment) as per the pyenv documentation*

## Setup

### Set Python version
Using pyenv (or similar), ensure the version of python you're using matches the one found in the ```pyproject.toml``` file.
#### pyenv

```bash
pyenv install 3.9.14
pyenv local 3.9.14  # Activate Python 3.9 for the current project
```

### Install Project Requirements
1. Checkout this repo to a location in your home directory.

2. Use [Poetry Install](https://python-poetry.org/docs/cli/#install) to install all project **and development** dependencies. 

   CD to the project root and run:
	``` bash
	poetry env use 3.9.14
	poetry install
	```
3. Validate that the install was successful by running ```poetry run chalice --version``` and you should see something similar to:

	*chalice 1.28.0, python 3.9.14, linux 5.15.0-72-generic* 


# Project layout
This project template combines a CDK application and a Chalice application.

These correspond to the ``infrastructure`` and ``runtime`` directory respectively. To run any **CDK CLI** commands, ensure you're in the ``infrastructure`` directory, and to run any **Chalice CLI** commands ensure you're in the ``runtime`` directory.

```console
.
├── README.md
├── chalice-cdk-project-files
│   ├── infrastructure # AWS CDK files 
│   │   ├── app.py
│   │   ├── cdk.json
│   │   ├── cdk.out
│   │   ├── chalice.out
│   │   └── stacks
│   └── runtime # Chalice app files 
│       ├── __pycache__
│       ├── app.py
│       ├── chalicelib 
│       └── requirements.txt
├── poetry.lock
├── pyproject.toml
└── tests
    └── __init__.py
```

# Develop and Deploy
## Local Development
### Poetry
The easiest way to activate the virtual environment is to create a nested shell with `poetry shell`.

To deactivate the virtual environment and exit this new shell type exit. To deactivate the virtual environment without leaving the shell use deactivate.
### Chalice Commands
Start a REST API using the local test server.
From within the `~/chalice-book-api-cdk/chalice-cdk-project-files/runtime` folder
```bash
# Start the virtual envioment 
poetry shell

# Start the test server
chalice local --port 2000
```

### Dynamodb & Docker
A local instance of Dynamodb can be used for development using Docker

```yaml
version: '3.8'
services:
  dynamodb-local:
    command: "-jar DynamoDBLocal.jar -sharedDb -dbPath ./data"
    image: "amazon/dynamodb-local:latest"
    container_name: dynamodb-local
    ports:
      - "8000:8000"
    volumes:
      - "./docker/dynamodb:/home/dynamodblocal/data"
    working_dir: /home/dynamodblocal
```
The app will check for the presence of the `AWS_CHALICE_CLI_MODE` environment variable and set the `DYNAMODB_HOST` to `"http://localhost:8000"`
___
Create a new table for local development with the AWS CLI
```shell![Markdown API Architecture](https://github.com/chris-birch/chalice-book-api-cdk/assets/21064947/0910d4e5-6888-4569-a9ef-9db4ec8421d5)

aws  dynamodb  create-table  \
	--table-name  Books  \
	--endpoint-url  http://localhost:8000  \
	--billing-mode  PAY_PER_REQUEST  \
	--attribute-definitions  '{
		"AttributeName": "pk",
		"AttributeType": "S"
	}'  \
	--key-schema  '{
		"AttributeName": "pk",
		"KeyType": "HASH"
	}'  \
```

## Deployment
### Requirements.txt
The AWS CDK expects that the projects dependencies are in the standard requirements.txt format, but as we're using Poetry for dependency, we need to export it using the `poetry export` command.
```bash
poetry  export  --without  dev  --without-hashes  -f  requirements.txt  --output  requirements.txt
```
The requirements.txt needs to be placed in the `runtime` folder.

It is recommended to use the `poetry lock --no-update` command before running export to ensure requirements.txt is correct.

### AWS CLI Configuration
Use the [aws configure](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html#cli-configure-files-methods) command to quickly setup access to Amazon AWS.

### CDK Deploy
If this is your first time using the CDK, you’ll need to bootstrap your account, which will deploy an AWS CloudFormation stack that contains resources needed to store our application. You can do this by running the `cdk bootstrap` command from the `infrastructure` directory.

We can now deploy our application using the `cdk deploy` command. Make sure you’re still in the `infrastructure` directory.

Ensure you've activated the **Poetry virtual environment** before running the `cdk deploy` command, or use `poetry run cdk deploy`.

[Deploying with the AWS CDK](https://aws.github.io/chalice/tutorials/cdk.html?highlight=cdk#project-creation)

