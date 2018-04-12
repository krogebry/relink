VERSION=`cat web/VERSION`

AWS_DEFAULT_REGION=us-east-1

pull_mongo:
	docker pull mongo:latest

tag_mongo:
	docker tag mongo:latest ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/mongo:latest

push_mongo:
	docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/mongo:latest

redir:
	cd docker ; docker build -t redir:latest -f redir.docker .

docker:
	docker build -t relink:${VERSION} .

tag:
	docker tag relink:${VERSION} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/relink:latest
	docker tag relink:${VERSION} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/relink:${VERSION}

push:
	docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/relink:latest
	docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/relink:${VERSION}

ecr_login:
	$(aws ecr get-login --no-include-email --AWS_DEFAULT_REGION ${AWS_DEFAULT_REGION})
