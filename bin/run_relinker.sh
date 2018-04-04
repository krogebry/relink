#!/usr/bin/env bash

docker run -d --rm -e "ENV_NAME=dev" -e "AWS_PROFILE=integration3" --name redir -v ~/.aws:/root/.aws -p 80:80 redir:latest
# docker run -ti --rm -e "ENV_NAME=dev" -e "AWS_PROFILE=integration3" --name redir \
    # -v ~/.aws:/root/.aws -p 80:80 redir:latest /bin/bash

