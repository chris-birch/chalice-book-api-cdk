import os

from aws_cdk import aws_lambda as _lambda
from aws_cdk import aws_ssm as ssm
from aws_cdk import aws_apigateway as apigateway

try:
    from aws_cdk import core as cdk
except ImportError:
    import aws_cdk as cdk

from chalice.cdk import Chalice


def getEnvironmentVariable(EnVarName):
    if EnVarName not in os.environ:
        errorMessage = '{} environment variable not found'.format(EnVarName)
        raise Exception(errorMessage)
    else:
        return os.getenv(EnVarName)
    
# These environment variables must be set to use custom domain names
API_DOMAIN_NAME = getEnvironmentVariable("CHALICE_API_DOMAIN_NAME")
CERTIFICATE_ARN = getEnvironmentVariable("CHALICE_CERTIFICATE_ARN")

RUNTIME_SOURCE_DIR = os.path.join(
    os.path.dirname(os.path.dirname(__file__)), os.pardir, 'runtime')

class ChaliceApp(cdk.Stack):
    
    def __init__(self, scope, id, **kwargs):
        super().__init__(scope, id, **kwargs)

        # Retrieve outputs created by Terraform
        books_table_name = ssm.StringParameter.from_string_parameter_attributes(
            self, "TableName", 
            parameter_name="/chalice_cdk_project/outputs/books_table/table_name"
        ).string_value

        api_handler_role = ssm.StringParameter.from_string_parameter_attributes(
            self, "RoleArn", 
            parameter_name="/chalice_cdk_project/outputs/api_handler/role_arn"
        ).string_value 

        # Dynamically configure Chalice app using CDK 
        self.chalice = Chalice(
            self, 'ChaliceApp', source_dir=RUNTIME_SOURCE_DIR,
            
            # When deploying with CDK, add stage configs here, not in config.json
            stage_config={
                "api_gateway_stage": "v1",
                'environment_variables': {
                    'APP_TABLE_NAME': books_table_name
                },
                "manage_iam_role": False,
                "iam_role_arn": api_handler_role,
                "api_gateway_custom_domain": {
                    "domain_name": API_DOMAIN_NAME,
                    "certificate_arn": CERTIFICATE_ARN,
                },
            }
        ) 

        # Save outputs needed to update Terraform assets later in the deployment
        cfn_api_handler_function = self.chalice.get_resource("APIHandler")
        api_handler_function = _lambda.Function.from_function_name(self, "MyFunction", cfn_api_handler_function.ref)
        
        ssm.StringParameter(self, "EndpointURL",
            description="Endpoint URL of the Chalice CDK API HAndler",
            parameter_name="/chalice_cdk_project/outputs/EndpointURL",
            string_value=self.chalice.sam_template.get_output("EndpointURL").value,
        )

        ssm.StringParameter(self, "ApiHandlerArn",
            description="API Handler Function ARN",
            parameter_name="/chalice_cdk_project/outputs/api_handler/function_arn",
            string_value=api_handler_function.function_arn,
        )

        cfn_api_gateway = apigateway.RestApi.from_rest_api_id(self, "api", rest_api_id="RestAPI")

        ssm.StringParameter(self, "RestAPIExecuteARN",
            description="API Handler Function ARN",
            parameter_name="/chalice_cdk_project/outputs/restApi/execute_arn",
            string_value=cfn_api_gateway.arn_for_execute_api("POST"),
        )