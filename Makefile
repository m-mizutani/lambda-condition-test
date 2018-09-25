AR_CONFIG ?= "param.cfg"

CODE_S3_BUCKET := $(shell cat $(AR_CONFIG) | grep CodeS3Bucket | cut -d = -f 2)
CODE_S3_PREFIX := $(shell cat $(AR_CONFIG) | grep CodeS3Prefix | cut -d = -f 2)
STACK_NAME := $(shell cat $(AR_CONFIG) | grep StackName | cut -d = -f 2)
PARAMETERS := $(shell cat $(AR_CONFIG) | grep -e MyParam | tr '\n' ' ')
TEMPLATE_FILE=template.yml

all: sam.yml

build/myfunc: ./functions/myfunc/*.go 
	env GOARCH=amd64 GOOS=linux go build -o build/myfunc ./functions/myfunc/

sam.yml: $(TEMPLATE_FILE) build/myfunc
	aws cloudformation package \
		--template-file $(TEMPLATE_FILE) \
		--s3-bucket $(CODE_S3_BUCKET) \
		--s3-prefix $(CODE_S3_PREFIX) \
		--output-template-file sam.yml

deploy: sam.yml
	aws cloudformation deploy \
		--template-file sam.yml \
		--stack-name $(STACK_NAME) \
		--capabilities CAPABILITY_IAM \
		--parameter-overrides $(PARAMETERS)
