# Déploiement d'un serveur de géocodage à la BAN (Base Adresse Nationale)

## Sommaire

**[Script d'initialisation du serveur - (init.sh)](#initsh)**

**[Script de lancement de l'instance - (start.sh)](#startsh)**

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
- 32 GB de RAM

Permettant de faire tourner :
- 1 instance Traefik,
- 1 instance Redis,
- 4 instances Addok.

(Donné à titre indicatif)

## Monitoring

Afin de vérifier que tout fonctionne correctement, il est intéressant de monitorer le serveur ainsi que les conteneurs Docker.

### Pour le serveur

```sh
htop
```

Permet de voir l'utilisation de la RAM, l'utilisation de l'ensemble des CPU.

Lors du lancement de l'instance de géocodage, il est possible de constater le chargement en RAM par Redis de la base de données BAN.

### Pour Docker
```sh
docker stats
```

Permet de voir, pour chaque conteneur lancé, l'utilisation de la RAM, l'utilisation CPU, le trafic réseau, les IO.

Cela permet de vérifier entre autres le niveau d'utilisation des conteneurs.

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

1. Lancement de traefik, qui fait fonction de réparation de charge
1. Lancement des conteneurs addok & redis

Il faut veiller à avoir le rapport Redis/Addok correct. Mes tests empiriques donnent 1 pour 16.

---
