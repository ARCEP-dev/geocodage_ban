#!/bin/bash
# params : nbr_redis nbr_addok


echo "Lancement de l'instance de géocodage"

echo "Lancement de traefik"
docker-compose -f traefik/traefik-compose.yml up -d

echo "Lancement d'addok"
docker-compose -f addok/addok-compose.yml up --scale addok=$2 --scale addok-redis=$1 -d
