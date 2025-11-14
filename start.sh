#!/bin/bash
# params : nbr_redis nbr_addok

echo "Lancement de l'instance de géocodage"
docker-compose -f addok/addok-compose.yml up --scale addok=$2 --scale addok-redis=$1 -d
