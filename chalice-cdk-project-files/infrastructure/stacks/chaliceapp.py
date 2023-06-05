import os
import json

from aws_cdk import aws_dynamodb as dynamodb
from aws_cdk import aws_apigateway as apigateway
from aws_cdk import aws_iam as iam
from aws_cdk import aws_s3 as s3
from aws_cdk import aws_lambda as _lambda
from aws_cdk import aws_s3_notifications as s3n

from devtools import debug

try:
    from aws_cdk import core as cdk
except ImportError:
    import aws_cdk as cdk

from chalice.cdk import Chalice


RUNTIME_SOURCE_DIR = os.path.join(
    os.path.dirname(os.path.dirname(__file__)), os.pardir, 'runtime')


class ChaliceApp(cdk.Stack):
    
    def __init__(self, scope, id, **kwargs):
        super().__init__(scope, id, **kwargs)
        self.dynamodb_table = self._create_ddb_table()
        self.user_api_gateway = self._create_user_api_gateway()
        self.chalice = Chalice(
            self, 'ChaliceApp', source_dir=RUNTIME_SOURCE_DIR,
            stage_config={
                'environment_variables': {
                    'APP_TABLE_NAME': self.dynamodb_table.table_name
                }
            }
        )

        self.dynamodb_table.grant_read_write_data(
            self.chalice.get_role('DefaultRole')
        )

    # !! CSV processor currently breaks CDK Deploy, will be fixed in future feature !!
    #
    #     cfn_my_function = self.chalice.sam_template.get_resource("MyFunction")
    #     self.my_function = _lambda.Function.from_function_name(self, "MyFunction", cfn_my_function.ref)
    #     self.csv_import_bucket = self._create_s3_import_bucket()

    # def _create_s3_import_bucket(self):
    #     fn = _lambda.Function(self, "MyBucketFunction",
    #         runtime=_lambda.Runtime.NODEJS_14_X,
    #         handler="index.handler",
    #         code=_lambda.Code.from_asset(RUNTIME_SOURCE_DIR)
    #     )

    #     debug(RUNTIME_SOURCE_DIR)
    #     bucket = s3.Bucket(self, "MyBucket")
    #     bucket.add_event_notification(s3.EventType.OBJECT_CREATED, s3n.LambdaDestination(fn))

    #     return bucket
 

    def _create_ddb_table(self):
        dynamodb_table = dynamodb.Table(
            self, 'AppTable',
            partition_key=dynamodb.Attribute(
                name='pk', type=dynamodb.AttributeType.STRING),
            removal_policy=cdk.RemovalPolicy.DESTROY)
        cdk.CfnOutput(self, 'AppTableName',
                      value=dynamodb_table.table_name)
        return dynamodb_table


    def _create_user_api_gateway(self):
    
        mapping_template = {
            "TableName": self.dynamodb_table.table_name,
            "FilterExpression": "book_id = :val",
            "ExpressionAttributeValues": {
                ":val": {
                    "N": "$input.params('book_id')"
                }
            }
        }

        # https://docs.aws.amazon.com/apigateway/latest/developerguide/models-mappings.html
        # Apache VTL
        response_template = """
#set($inputRoot = $input.path('$'))
[#foreach($elem in $inputRoot.Items) {
    "pk": "$elem.pk.S",
    "book_id": "$elem.book_id.N",
    "isbn": "$elem.isbn.N",
    "authors": "$elem.authors.S",
    "original_publication_year": "$elem.original_publication_year.N",
    "title": "$elem.title.S",
    "language_code": "$elem.language_code.S",
    "average_rating": "$elem.average_rating.N"
}#if($foreach.hasNext),#end
#end]
"""

        dynamodb_scan_policy_statement = iam.PolicyStatement(
            effect=iam.Effect.ALLOW,
            actions=[
                'dynamodb:Scan',
            ],
            resources=[
                self.dynamodb_table.table_arn,
            ],
        )

        dynamodb_scan_role = iam.Role(
            self, "dynamodb-scan-role",
            assumed_by=iam.ServicePrincipal("apigateway.amazonaws.com"),
        )

        dynamodb_scan_role.add_to_principal_policy(dynamodb_scan_policy_statement)
        
        
        get_book_intergration = apigateway.AwsIntegration(
            service="dynamodb",
            integration_http_method="POST",
            region="eu-west-2",
            action="Scan",
            options= apigateway.IntegrationOptions(
                credentials_role=dynamodb_scan_role,
                request_templates={
                    "application/json": "{}".format(json.dumps(mapping_template))
                },
                integration_responses=[
                    apigateway.IntegrationResponse(
                        status_code="200", 
                        response_templates ={
                            "application/json": "{}".format(response_template)
                            }
                        )
                    ]
            )
        )
        
        user_api = apigateway.RestApi(self, "user_api")
        book_resource = user_api.root.add_resource("{book_id}")
        book_resource.add_method("GET", get_book_intergration, api_key_required=True).add_method_response(status_code="200")

        usage_plan = user_api.add_usage_plan("UsagePlan",
            name="UserUsagePlan",
            throttle=apigateway.ThrottleSettings(
                rate_limit=10,
                burst_limit=2
            )
        )

        api_key = user_api.add_api_key("MyApiKey", api_key_name="MyApiKey")
        usage_plan.add_api_key(api_key)

        return user_api