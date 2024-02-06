import os

import schemathesis

def getEnvironmentVariable(EnVarName):
    if EnVarName not in os.environ:
        errorMessage = '{} environment variable not found'.format(EnVarName)
        raise Exception(errorMessage)
    else:
        return os.getenv(EnVarName)
    
# These environment variables must be set to use custom domain names
USER_API_URL = getEnvironmentVariable("USER_API_URL")
USER_API_KEY = getEnvironmentVariable("USER_API_KEY")

schema = schemathesis.from_uri("https://raw.githubusercontent.com/chris-birch/chalice-book-api-cdk/main/swagger/user-api-swagger.yaml",
                                base_url=USER_API_URL)


@schemathesis.check
def status_not_403(response, case) -> None:
    if response.status_code == 403:
        raise AssertionError("None valid status code")

@schema.parametrize()
def test_api(case):
    api_response = case.call(headers={"x-api-key": USER_API_KEY})
    case.validate_response(response=api_response, additional_checks=(status_not_403,))