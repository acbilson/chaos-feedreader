#!/bin/bash
. .env

ENVIRONMENT=$1

case $ENVIRONMENT in

uat)
  echo "creates pod in uat..."
  ssh -t ${UAT_HOST} \
    sudo podman pod create --name feedreader --publish ${UAT_EXPOSED_PORT}:8080

  echo "runs db container in uat..."
  ssh -t ${UAT_HOST} \
    sudo podman run --rm -d \
      -e "POSTGRES_PASSWORD=${DB_PASSWORD}" \
      -v ${UAT_DB_PATH}:/var/lib/postgresql/data \
      --pod feedreader \
      --name feedreader-db-uat \
      acbilson/feedreader-db-uat:alpine

  echo "runs container in uat..."
  ssh -t ${UAT_HOST} \
    sudo podman run --rm -d \
      -e \"DATABASE_URL=postgres://postgres:${DB_PASSWORD}@localhost/postgres?sslmode=disable\" \
      -e "RUN_MIGRATIONS=1" \
      -e "CREATE_ADMIN=1" \
      -e "ADMIN_USERNAME=miniflux" \
      -e "ADMIN_PASSWORD=${UAT_ADMIN_PASSWORD}" \
      --pod feedreader \
      --name feedreader-uat \
      acbilson/feedreader-uat:latest

;;

prod)
  echo "enabling feedreader pod..."
  ssh -t ${PROD_HOST} sudo systemctl daemon-reload
  ssh -t ${PROD_HOST} sudo systemctl enable --now pod-feedreader.service
;;

*)
  echo "please provide one of the following as the first argument: uat, prod."
  exit 1

esac
