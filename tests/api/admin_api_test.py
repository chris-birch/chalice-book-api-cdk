import os

import schemathesis
from requests_aws4auth import AWS4Auth
from botocore.session import Session

def getEnvironmentVariable(EnVarName):
    if EnVarName not in os.environ:
        errorMessage = '{} environment variable not found'.format(EnVarName)
        raise Exception(errorMessage)
    else:
        return os.getenv(EnVarName)
    
# These environment variables must be set to use custom domain names
ADMIN_API_URL = getEnvironmentVariable("ADMIN_API_URL")


credentials = Session().get_credentials()
auth = AWS4Auth(region='eu-west-2', service='execute-api',
                    refreshable_credentials=credentials)

schema = schemathesis.from_uri("https://raw.githubusercontent.com/chris-birch/chalice-book-api-cdk/main/swagger/admin-api-swagger.yaml",
                                base_url=ADMIN_API_URL)


schema.auth.set_from_requests(auth=auth)

@schema.parametrize()
def test_api(case):
    case.call_and_validate()