# Déploiement d'un serveur de géocodage à la BAN (Base Adresse Nationale)

## Sommaire

**[Remarque globale](#remarqueglobale)**

**[Monitoring](#monitoring)**

**[Script d'initialisation du serveur - (init.sh)](#initsh)**

**[Script de lancement de l'instance - (start.sh)](#startsh)**

**[Mise à jour de la base de données](#mise-à-jour-de-la-base-de-données)**

## Remarque globale

Ce dépôt a pour vocation à préparer, le plus automatiquement possible, un serveur pour en faire une machine de géocodage.

L'API de géocodage sera exposée sur l'URL :
http://server_ip/addok/search/

Exemple :
http://server_ip/addok/search/?q=14+rue+Gerty+Archim%C3%A8de+75012+Paris&limit=1

### Prérequis matériels

Un serveur UNIX (testé sous Debian), avec un accès Internet et une exposition du port 80.

Il faut prévoir suffisamment de CPU pour permettre de faire s'exécuter l'ensemble des conteneurs.

Il faut prévoir autant de RAM qu'il y aura d'instances de Redis lancées, qui chargeront la base de données.

**Recommandations minimales :**
- 8 CPU
- 12 GB de RAM

Permettant de faire tourner (à titre indicatif) :
- 1 instance Traefik,
- 1 instance Redis,
- 8-16 instances Addok.

### Limitation actuelle

En l'état actuel, il n'est possible de lier les conteneurs addok qu'à un seul conteneur redis.

Toute aide et/ou compétence sur le sujet est la bienvenue.

## Monitoring

Afin de vérifier que les resources matérielles sont utilisées le plus optimalement possible sans saturation, il est intéressant de monitorer le serveur ainsi que les conteneurs Docker.

### Pour le serveur

```sh
htop
```

Permet de voir l'utilisation de la RAM, l'utilisation de l'ensemble des CPU.

Lors du lancement de l'instance de géocodage, il est possible de constater le chargement en RAM par Redis de la base de données BAN.

### Pour Docker

La commande **docker stats**, permet de voir, pour chaque conteneur lancé, l'utilisation de la RAM, du CPU, le trafic réseau, les IO.

Cela permet de vérifier entre autres le niveau d'utilisation des conteneurs.

```sh
docker stats

# Exemple
CONTAINER ID        NAME                  CPU %               MEM USAGE / LIMIT     MEM %               NET I/O             BLOCK I/O           PIDS
86f162f2c545        addok_addok_4         0.05%               577.7MiB / 28.76GiB   1.96%               18.6GB / 43.2GB     0B / 401kB          11
6b3debd7317b        addok_addok_1         0.08%               579.8MiB / 28.76GiB   1.97%               18.6GB / 43GB       8.19kB / 0B         11
5844727417c2        addok_addok_2         0.19%               578.9MiB / 28.76GiB   1.97%               18.5GB / 43GB       8.19kB / 73.7kB     11
e0ec7b335f8c        addok_addok_3         0.15%               579.4MiB / 28.76GiB   1.97%               18.5GB / 42.8GB     0B / 0B             11
b4b7399edd6f        addok_addok-redis_1   0.12%               5.007GiB / 28.76GiB   17.41%              282GB / 108GB       0B / 0B             4
ce34d9209ff5        traefik_proxy_1       0.03%               15.98MiB / 28.76GiB   0.05%               306GB / 323GB       23.9MB / 0B         28
```

La commande **docker ps** permet de lister les conteneurs avec leur id, leur nom, leur status ...

```sh
docker ps

# Exemple
CONTAINER ID        IMAGE                COMMAND                  CREATED             STATUS              PORTS                NAMES
86f162f2c545        etalab/addok         "/bin/sh -c docker-e…"   2 days ago          Up 2 days           7878/tcp             addok_addok_4
6b3debd7317b        etalab/addok         "/bin/sh -c docker-e…"   2 days ago          Up 2 days           7878/tcp             addok_addok_1
5844727417c2        etalab/addok         "/bin/sh -c docker-e…"   2 days ago          Up 2 days           7878/tcp             addok_addok_2
e0ec7b335f8c        etalab/addok         "/bin/sh -c docker-e…"   2 days ago          Up 2 days           7878/tcp             addok_addok_3
b4b7399edd6f        etalab/addok-redis   "docker-entrypoint.s…"   2 days ago          Up 2 days           6379/tcp             addok_addok-redis_1
ce34d9209ff5        traefik:latest       "/traefik --docker -…"   4 months ago        Up 4 months         0.0.0.0:80->80/tcp   traefik_proxy_1
```

---

## init.sh

Script de préparation du serveur (installation des paquets nécessaires, téléchargement des données et des fichiers de config).

### Prérequis

Exécuter les commandes suivantes afin de télécharger le script sur le serveur :
```sh
wget -O ~/init.sh https://raw.githubusercontent.com/ARCEP-dev/geocodage_ban/master/init.sh
chmod u+x ./init.sh
```

### Lancement
```sh
./init.sh
```

### Fonctionnement

1. Téléchargement du script de vérification de l'environnement
1. Vérification que OVERLAY FS soit bien activé
1. Mise à jour des dépôts et installations
1. Ajout du dépôt docker
1. Mise à jour des dépôts et installation de docker
1. Ajouter le service au démarrage
1. Ajout de l'utilisateur au groupe docker
1. Vérification de la version de Docker
1. Création des répertoires pour l'instance de géocodage
1. Téléchargement de la dernière version des données BAN
1. Téléchargement des docker-compose à la sauce Arcep
1. Téléchargement du script de lancement de l'instance de géocodage
1. Redémarrage du serveur

Il est nécessaire de fermer et rouvrir sa session pour que les changements de droits soient effectifs. La solution que j'ai choisie est de redémarrer le serveur en fin de script.

---

## start.sh

Script de lancement de l'instance de géocodage.

### Dépendances

- Aucune

### Lancement
```sh
./start.sh nbr_redis nbr_addok
```

### Paramètres
- **nbr_redis** : Nombre de conteneurs Redis (Base de données In Memory)
- **nbr_addok** : Nombre de conteneurs Addok (API de géocodage)

### Fonctionnement

1. Lancement de traefik, qui fait fonction de load balancer
1. Lancement des conteneurs addok & redis

Il faut veiller à avoir le rapport Redis/Addok correct. Mes tests empiriques donnent 1 pour 16.

---

## Mise à jour de la base de données

Il peut être nécessaire de mettre à jour l'instance de géocodage avec des données plus récentes de la BAN. Pour ce faire, il faut :
1. stopper l'instance en cours,
1. télécharger la nouvelle base de données,
1. relancer l'instance.

### Arrêt de l'instance en cours
```sh
docker-compose -f /opt/geocoding/addok/addok-compose.yml down
```

### Remplacement de la base de données
```sh
# Téléchargement de la base de données
wget -O /tmp/addok-france-bundle.zip https://adresse.data.gouv.fr/data/ban/adresses/AAAA-MM-JJ/addok/addok-france-bundle.zip

# Création d'un répertoire de désarchivage
mkdir  /tmp/data

unzip -d /tmp/data /tmp/addok-france-bundle.zip

# Déplacement des fichiers dans le répertoire de l'instance
sudo mv /tmp/data/* /opt/geocoding/addok/addok-data/

sudo chown debian:root /opt/geocoding/addok/addok-data/*

# Suppression de l'archive
rm /tmp/addok-france-bundle.zip
```

### Redémarrage de l'instance

Il y a deux façons de faire.

Si l'instance a été stoppée via :

```sh
docker-compose -f /opt/geocoding/addok/addok-compose.yml down
```

alors, le réseau **traefik** existe toujours (car il est externe) et le conteneur **traefik** est toujours en fonctionnement, ce qui peut se vérifier via

```sh
docker ps
```

dans ce cas, il faut utiliser la commande :

```sh
docker-compose -f addok/addok-compose.yml up --scale addok=X --scale addok-redis=Y -d
```

où X et Y sont les nombres de conteneurs, respectivement d'addok et de redis.

Dans le cas-où, traefik ne fonctionnerait plus et que son réseau ne serait plus existant, il faut utiliser le script **start.sh**.
