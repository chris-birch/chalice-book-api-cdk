# Book Management API

Am AWS hosted RESTful API for data transfer with a web front-end for management and a database for storage utilizing [serverless](https://www.redhat.com/en/topics/cloud-native-apps/what-is-serverless "https://www.redhat.com/en/topics/cloud-native-apps/what-is-serverless") architecture.

Using the [Chalice](https://aws.github.io/chalice/ "https://aws.github.io/chalice/") framework to deploy most of the architecture and [AWS Cloud Development Kit (AWS CDK)](https://docs.aws.amazon.com/cdk/v2/guide/home.html "https://docs.aws.amazon.com/cdk/v2/guide/home.html") to deploy the remaining (serverless) components. The web management console and user authentication is deployed using [AWS Amplify](https://aws.amazon.com/amplify/ "https://aws.amazon.com/amplify/").


## Architecture 

AWS PICTURE HERE

# Quick Start
## Requirements
### Poetry
Poetry is a tool for **dependency management** and **packaging** in Python.

See the [Installation](https://python-poetry.org/docs/#installation) guide for more information.

```curl -sSL https://install.python-poetry.org | python3 -```

Poetry requires **Python 3.7+**

### AWS CDK
You'll need to install the AWS CDK if you haven't already.

See [Getting Started](https://docs.aws.amazon.com/cdk/latest/guide/getting_started.html) with the AWS CDK guide for more details.

```$ npm install -g aws-cdk```

The CDK requires [Node.js and npm](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm) to run.

### pyenv
Using [pyenv](https://github.com/pyenv/pyenv#readme) to manage per project python versions.

installing with [Homebrew](https://brew.sh):
```
brew update
brew install pyenv
```
## Setup
### Install Project Requirements
Use [Poetry Install](https://python-poetry.org/docs/cli/#install) to install all project **and development** dependencies. 

CD to the project root and run ```poetry install```

# Project layout
This project template combines a CDK application and a Chalice application.

These correspond to the ``infrastructure`` and ``runtime`` directory respectively. To run any **CDK CLI** commands, ensure you're in the ``infrastructure`` directory, and to run any **Chalice CLI** commands ensure you're in the ``runtime`` directory.

