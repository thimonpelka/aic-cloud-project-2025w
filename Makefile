.PHONY: help install bootstrap deploy destroy diff synth logs clean start-localstack stop-localstack status

# LocalStack configuration
LOCALSTACK_ENDPOINT = http://localhost:4566
AWS_REGION = us-east-1
AWS_ACCOUNT_ID = 000000000000

# CDK configuration
CDK_CMD = cdklocal

help:
	@echo "LocalStack CDK Deployment Commands:"
	@echo "  make install          - Install Python dependencies"
	@echo "  make start-localstack - Start LocalStack container"
	@echo "  make stop-localstack  - Stop LocalStack container"
	@echo "  make status          - Check LocalStack status"
	@echo "  make bootstrap       - Bootstrap CDK for LocalStack"
	@echo "  make synth           - Synthesize CloudFormation template"
	@echo "  make diff            - Show differences between deployed and local"
	@echo "  make deploy          - Deploy stack to LocalStack"
	@echo "  make destroy         - Destroy stack from LocalStack"
	@echo "  make logs            - Tail LocalStack logs"
	@echo "  make clean           - Clean generated files"
	@echo "  make all             - Install, start LocalStack, bootstrap, and deploy"

install:
	@echo "Installing dependencies..."
	pip install -r requirements.txt
	pip install awscli-local[ver1]
	npm install -g aws-cdk-local aws-cdk

start-localstack:
	@echo "Starting LocalStack..."
	@docker-compose up -d
	@echo "Waiting for LocalStack to be ready..."
	@sleep 15
	@echo "LocalStack is ready!"

stop-localstack:
	@echo "Stopping LocalStack..."
	@docker-compose down

status:
	@echo "Checking LocalStack status..."
	@curl -s $(LOCALSTACK_ENDPOINT)/_localstack/health | python3 -m json.tool || echo "LocalStack is not running"

bootstrap:
	@echo "Bootstrapping CDK for LocalStack..."
	$(CDK_CMD) bootstrap aws://$(AWS_ACCOUNT_ID)/$(AWS_REGION)

synth:
	@echo "Synthesizing CloudFormation template..."
	$(CDK_CMD) synth

diff:
	@echo "Showing stack differences..."
	$(CDK_CMD) diff

deploy:
	@echo "Deploying to LocalStack..."
	$(CDK_CMD) deploy --require-approval never

destroy:
	@echo "Destroying stack from LocalStack..."
	$(CDK_CMD) destroy --force

logs:
	@echo "Tailing LocalStack logs..."
	docker logs -f localstack

clean:
	@echo "Cleaning generated files..."
	rm -rf cdk.out
	rm -rf .cdk.staging
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete

all: install start-localstack bootstrap deploy
	@echo "✅ Deployment complete!"
