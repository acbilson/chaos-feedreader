#!/bin/bash
. .env

ENVIRONMENT=$1

case $ENVIRONMENT in

uat)
  echo "creates files from template..."
  mkdir -p dist

  echo "copies files to distribute..."
  cp Dockerfile* dist/

  echo "distributes dist/ folder..."
  scp -r dist ${UAT_HOST}:/mnt/msata/build/uat

  echo "builds db image on UAT"
  ssh -t ${UAT_HOST} \
    sudo podman build \
      -f /mnt/msata/build/uat/Dockerfile-db \
      -t acbilson/feedreader-db-uat:alpine \
      /mnt/msata/build/uat

  echo "builds image on UAT"
  ssh -t ${UAT_HOST} \
    sudo podman build \
      -f /mnt/msata/build/uat/Dockerfile \
      -t acbilson/feedreader-uat:latest \
      /mnt/msata/build/uat

;;

prod)
  echo "creates files from template..."
  mkdir -p dist
  envsubst < template/pod-feedreader.service > dist/pod-feedreader.service
  envsubst < template/container-feedreader-db.service > dist/container-feedreader-db.service
  envsubst < template/container-feedreader.service > dist/container-feedreader.service

  echo "copies files to distribute..."
  cp Dockerfile* dist/

  echo "distributes dist/ folder..."
  scp -r dist ${PROD_HOST}:/mnt/msata/build/prod

  echo "builds db image on production"
  ssh -t ${PROD_HOST} \
    sudo podman build \
      -f /mnt/msata/build/prod/Dockerfile-db \
      -t acbilson/feedreader-db:alpine \
      /mnt/msata/build/prod

  echo "builds image on production"
  ssh -t ${PROD_HOST} \
    sudo podman build \
      -f /mnt/msata/build/prod/Dockerfile \
      -t acbilson/feedreader:latest \
      /mnt/msata/build/prod
;;

*)
  echo "please provide one of the following as the first argument: uat, prod."
  exit 1

esac
