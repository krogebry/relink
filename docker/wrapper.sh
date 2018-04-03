#!/usr/bin/env bash

export URL=$(aws --region us-east-1 ssm get-parameters --names "/relinker/${ENV_NAME}/alb/hostname"|jq -r '.Parameters[0].Value')

sed -i "s/URL/${URL}/" /etc/nginx/nginx.conf

/etc/init.d/nginx restart
