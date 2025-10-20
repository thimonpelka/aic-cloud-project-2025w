import aws_cdk as core
import aws_cdk.assertions as assertions

from infrastructure.service_stack import ServiceStack

# example tests. To run these tests, uncomment this file along with the example
# resource in test/test_stack.py


def test_sqs_queue_created():
    app = core.App()
    stack = ServiceStack(app, "test")
    template = assertions.Template.from_stack(stack)

#     template.has_resource_properties("AWS::SQS::Queue", {
#         "VisibilityTimeout": 300
#     })
