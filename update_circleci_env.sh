#!/usr/bin/env bash

#update circleci with the environment variables of the temporary ftp server
#using credentials from pass
#MANUAL STEP

CIRCLE_API_TOKEN=$(pass circleci.com/PERSONAL_API_TOKENS/UPDATE_CIRCLECI_FROM_TERRAFORM);
CIRCLE_PROJECT_SLUG=$(pass circleci.com/PROJECT_SLUG);

FTP_USER_PRIVATE_KEY=$(terraform output -raw private_key)
FTP_USER_NAME=$(terraform output -raw ftp_user)
FTP_SERVER_ENDPOINT=$(terraform output -raw endpoint)

curl --request POST \
  --url "https://circleci.com/api/v2/project/${CIRCLE_PROJECT_SLUG}/envvar" \
  --header "Circle-Token: $CIRCLE_API_TOKEN" \
  --header 'content-type: application/json' \
  --data '{
    "name": "CIRCLE_PROJECT_SLUG",
    "value": "'"$CIRCLE_PROJECT_SLUG"'"
  }'

curl --request POST \
  --url "https://circleci.com/api/v2/project/${CIRCLE_PROJECT_SLUG}/envvar" \
  --header "Circle-Token: $CIRCLE_API_TOKEN" \
  --header 'content-type: application/json' \
  --data '{
    "name": "FTP_USER_PRIVATE_KEY",
    "value": "'"$FTP_USER_PRIVATE_KEY"'"
  }'

curl --request POST \
  --url "https://circleci.com/api/v2/project/${CIRCLE_PROJECT_SLUG}/envvar" \
  --header "Circle-Token: $CIRCLE_API_TOKEN" \
  --header 'content-type: application/json' \
  --data '{
    "name": "FTP_USER_NAME",
    "value": "'"$FTP_USER_NAME"'"
  }'

curl --request POST \
  --url "https://circleci.com/api/v2/project/${CIRCLE_PROJECT_SLUG}/envvar" \
  --header "Circle-Token: $CIRCLE_API_TOKEN" \
  --header 'content-type: application/json' \
  --data '{
    "name": "FTP_SERVER_ENDPOINT",
    "value": "'"$FTP_SERVER_ENDPOINT"'"
  }'