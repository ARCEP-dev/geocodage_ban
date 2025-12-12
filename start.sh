#!/bin/bash
# params : nbr_redis nbr_addok
echo "Lancement d'addok"
docker-compose up --scale addok=$2 --scale addok-redis=$1 -d
