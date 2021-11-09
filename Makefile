step1-create-table:
	aws dynamodb create-table \
    --table-name BarkTable \
    --attribute-definitions AttributeName=Username,AttributeType=S AttributeName=Timestamp,AttributeType=S \
    --key-schema AttributeName=Username,KeyType=HASH  AttributeName=Timestamp,KeyType=RANGE \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --stream-specification StreamEnabled=true,StreamViewType=NEW_AND_OLD_IMAGES

step2a-create-role:
	aws iam create-role --role-name WooferLambdaRole \
    --path "/service-role/" \
    --assume-role-policy-document file://trust-relationship.json

step2b-put-role-policy:
	aws iam put-role-policy --role-name WooferLambdaRole \
    --policy-name WooferLambdaRolePolicy \
    --policy-document file://role-policy.json

step3a-create-topic:
	aws sns create-topic --name wooferTopic

step3b-subscribe:
	aws sns subscribe \
    --topic-arn arn:aws:sns:eu-central-1:820221600447:wooferTopic \
    --protocol email \
    --notification-endpoint gipszlyakab@gmail.com

build:
	zip publishNewBark.zip publishNewBark.js

step4-create-function: build
	aws lambda create-function \
    --region eu-central-1 \
    --function-name publishNewBark \
    --zip-file fileb://publishNewBark.zip \
    --role $(shell aws iam list-roles --query "Roles[?RoleName=='WooferLambdaRole'].Arn" --out text) \
    --handler publishNewBark.handler \
    --timeout 5 \
    --runtime nodejs14.x

update-function-code:
	aws lambda update-function-code \
	--function-name publishNewBark \
	--zip-file fileb://publishNewBark.zip

step5-create-trigger:
	aws lambda create-event-source-mapping \
    --region eu-central-1 \
    --function-name publishNewBark \
    --event-source $(shell aws dynamodb describe-table --table-name BarkTable --query Table.LatestStreamArn --out text)  \
    --batch-size 1 \
    --starting-position TRIM_HORIZON

test-payload:
	aws lambda invoke \
	--function-name publishNewBark \
	--cli-binary-format raw-in-base64-out \
	--payload file://payload.json output.txt


# make put-item name="Nagy Odon"
put-item:
	aws dynamodb put-item \
    --table-name BarkTable \
    --item Username={S="$(name)"},Timestamp={S="$(shell date +%Y-%m-%d:%H:%M:%S)"},Message={S="Testing...1...2...3"}