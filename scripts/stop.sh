#!/bin/bash
. .env

ENVIRONMENT=$1

case $ENVIRONMENT in

uat)
  echo "stops db container in uat..."
  ssh -t ${UAT_HOST} \
    sudo podman stop feedreader-db-uat

  echo "stops container in uat..."
  ssh -t ${UAT_HOST} \
    sudo podman stop feedreader-uat

  echo "removes pod in uat..."
  ssh -t ${UAT_HOST} \
    sudo podman pod rm feedreader
;;

prod)
  echo "stops container in production..."
  ssh -t ${PROD_HOST} sudo systemctl disable feedreader-db
  ssh -t ${PROD_HOST} sudo podman stop feedreader-db
  ssh -t ${PROD_HOST} sudo systemctl disable feedreader
  ssh -t ${PROD_HOST} sudo podman stop feedreader
  ssh -t ${PROD_HOST} sudo podman pod rm feedreader
;;

*)
  echo "please provide one of the following as the first argument: uat, prod."
  exit 1

esac
