VERSION=`cat web/VERSION`
# USER_NAME=ec2-user
# USER_ID=500

REGION=us-east-1

tag_mongo:
	docker tag mongo:latest ${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/mongo:latest

push_mongo:
	docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/mongo:latest

redir:
	cd docker ; docker build -t redir:latest -f redir.docker .

run_redir:
	# docker rm redir
	docker run --rm -e "ENV_NAME=dev" -e "AWS_PROFILE=${AWS_PROFILE}" --name redir -v ~/.aws:/root/.aws -p 80:80 redir:latest

docker:
	docker build -t relink:${VERSION} .

push:
	docker tag relink:${VERSION} ${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/relink:latest
	docker tag relink:${VERSION} ${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/relink:${VERSION}

	docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/relink:latest
	docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/relink:${VERSION}

get_login:
	`aws ecr get-login --no-include-email --region ${REGION}`
