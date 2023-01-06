#!/usr/bin/env bash

# Fail if anything within this script returns
# a non-zero exit code
set -e

if [ "${CIRCLE_BRANCH}" == "production" ]
then
  echo "Logging into cloud.gov"
  # Log into CF and push
  cf login -a $CF_API_ENDPOINT -u $CF_PRODUCTION_SPACE_DEPLOYER_USERNAME -p $CF_PRODUCTION_SPACE_DEPLOYER_PASSWORD -o $CF_ORG -s prod
  echo "PUSHING to PRODUCTION..."
  cf v3-zdt-push touchpoints-production-sidekiq-worker
  cf v3-zdt-push touchpoints
  echo "Push to Production Complete."
else
  echo "Not on the production branch."
fi

if [ "${CIRCLE_BRANCH}" == "main" ]
then
  echo "Logging into cloud.gov"
  # Log into CF and push
  cf login -a $CF_API_ENDPOINT -u $CF_USERNAME -p $CF_PASSWORD -o $CF_ORG -s $CF_SPACE
  echo "Pushing to Demo..."
  cf v3-zdt-push touchpoints-demo-sidekiq-worker
  cf v3-zdt-push touchpoints-demo
  echo "Push to Demo Complete."
else
  echo "Not on the main branch."
fi

if [ "${CIRCLE_BRANCH}" == "develop" ]
then
  echo "Logging into cloud.gov"
  # Log into CF and push
  cf login -a $CF_API_ENDPOINT -u $CF_USERNAME -p $CF_PASSWORD -o $CF_ORG -s $CF_SPACE
  echo "Pushing to Staging..."
  cf v3-zdt-push touchpoints-staging-sidekiq-worker
  cf v3-zdt-push touchpoints-staging
  echo "Push to Staging Complete."
else
  echo "Not on the develop branch."
fi
