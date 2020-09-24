ENV ?= local
REGION ?= ap-southeast-2
ARTIFACT_BUCKET:=fn-artifacts
OPTIONS ?= --endpoint-url=http://localhost:4566
PROFILE ?= local

clean:
	rm -rf .localstack

wait:
	@until aws ${OPTIONS} --profile ${PROFILE} s3 ls &>/dev/null ; do printf . ; sleep 1 ; done
	@printf "Stack Ready\n"

docker-up:
	TMPDIR=/private$$TMPDIR docker-compose -f docker-compose.yml up -d --force-recreate --remove-orphans

docker-down:
	docker-compose -f docker-compose.yml down

setup-artifact:
	aws ${OPTIONS} --profile ${PROFILE} s3 mb s3://${ARTIFACT_BUCKET}

start-stack: clean docker-up wait setup-artifact

stop-stack: docker-down clean

check-stack:
	@printf "** listing aws buckets:\n"
	aws ${OPTIONS} --profile ${PROFILE} s3 ls
	@printf "** listing lambda functions:\n"
	aws ${OPTIONS} --profile ${PROFILE} lambda list-functions
