#!/usr/bin/env bash

echo "ENV: ${ENV_NAME}"
export DB_HOSTNAME=$(aws --region us-east-1 ssm get-parameters --names "/relinker/${ENV_NAME}/db/hostname"|jq -r '.Parameters[0].Value')
echo "DBHostname: ${DB_HOSTNAME}"

./api.rb
