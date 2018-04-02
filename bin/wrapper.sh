#!/usr/bin/env bash

export DB_HOSTNAME=$(aws --region us-east-1 ssm get-parameters --names "/relinker/database/url"|jq -r '.Parameters[0].Value')

./api.rb
