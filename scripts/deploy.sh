#!/bin/bash
. .env

ENVIRONMENT=$1

case $ENVIRONMENT in

uat)
  echo "runs db container in uat..."
  ssh -t ${UAT_HOST} \
    sudo podman run --rm -d \
      -p ${UAT_EXPOSED_PORT}:5432 \
      -e "POSTGRES_PASSWORD=${DB_PASSWORD}" \
      -v ${UAT_DB_PATH}:/var/lib/postgresql/data
      --name feedreader-db-uat \
      acbilson/feedreader-db-uat:alpine

  echo "TODO: runs container in uat..."
;;

prod)
  echo "enabling micropub service..."
  ssh -t ${PROD_HOST} sudo systemctl daemon-reload
  ssh -t ${PROD_HOST} sudo systemctl enable --now container-feedreader-db.service
  ssh -t ${PROD_HOST} sudo systemctl enable --now container-feedreader.service
;;

*)
  echo "please provide one of the following as the first argument: uat, prod."
  exit 1

esac
