REGION ?= ap-southeast-2

# Where do we want our zip functions to be deployed to
ARTIFACT_BUCKET:=fn-artifacts

# For real AWS aws cli commands, set OPTION to be empty
OPTIONS ?= --endpoint-url=http://localhost:4566

# AWS_PROFILE
PROFILE ?= local

LAMBDA_ROLE ?= arn:aws:iam:1234:role/lambda_basic_execution

default: stack-restart clean lambda-js-hw-deploy lambda-js-hw-invoke

clean:
	rm -rf ./fn-js-hello-world/lambda.zip
	rm -rf response.json

## Wait checks that localstack is up and running by listing an S3 bucket
wait:
	@until aws ${OPTIONS} --profile ${PROFILE} s3 ls &>/dev/null ; do printf . ; sleep 1 ; done
	@printf "Stack Ready\n"

docker-up:
	TMPDIR=/private$$TMPDIR docker-compose -f docker-compose.yml up -d --force-recreate --remove-orphans

docker-down:
	docker-compose -f docker-compose.yml down

stack-start: clean docker-up wait setup-artifact

stack-stop: docker-down
	rm -rf .localstack

stack-restart: stack-stop stack-start

stack-check:
	@printf "** listing aws buckets:\n"
	aws ${OPTIONS} --profile ${PROFILE} s3 ls
	@printf "** listing lambda functions:\n"
	aws ${OPTIONS} --profile ${PROFILE} lambda list-functions

setup-artifact:
	aws ${OPTIONS} --profile ${PROFILE} s3 mb s3://${ARTIFACT_BUCKET}

lambda-js-hw-deploy:
	cd fn-js-hello-world; \
	rm -rf lambda.zip; \
	zip lambda.zip lambda.js; \
	aws ${OPTIONS} --profile ${PROFILE} lambda create-function \
    --region ${REGION} \
    --function-name fn-js-hello-world \
    --runtime nodejs8.10 \
    --handler lambda.hwHandler \
	--timeout 15 \
    --memory-size 128 \
    --zip-file fileb://lambda.zip \
    --role ${LAMBDA_ROLE}

lambda-js-hw-delete:
	aws ${OPTIONS} --profile ${PROFILE} lambda delete-function  --function-name fn-js-hello-world

lambda-js-hw-redeploy: lambda-js-hw-delete lambda-js-hw-deploy

lambda-js-hw-invoke:
	aws ${OPTIONS} --profile ${PROFILE} lambda invoke --function-name fn-js-hello-world --payload fileb://testdata/event.json response.json
	@cat response.json
