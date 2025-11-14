#!/bin/bash

echo "Script de préparation du serveur pour le déploiement d'une instance de géocodage"

echo "Téléchargement d'un script de vérification de l'environnement"
wget https://raw.githubusercontent.com/moby/moby/master/contrib/check-config.sh
chmod +x check-config.sh
echo "Vérification que OVERLAY FS soit bien activé : "
./check-config.sh | grep CONFIG_OVERLAY_FS

echo "Mise à jour des dépôts et installations"
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common htop unzip python3

echo "Ajout du dépôt docker aux sources"
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo add-apt-repository    "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"

echo "Mise à jour des dépôts et installation de docker"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

echo "Ajouter le service au démarrage"
sudo systemctl enable docker

echo "Ajout de l'utilisateur au groupe docker"
sudo usermod -aG docker $USER
echo "Il est nécessaire de se reconnecter pour bénéficier des privilèges"

echo "Vérification de la version de Docker"
docker version
docker info

echo "Création des répertoires pour l'instance de géocodage"
sudo mkdir -p /opt/geocodage/
cd /opt/geocodage/
sudo mkdir -p addok-data

echo "Téléchargement de la dernière version des données BAN"
wget https://adresse.data.gouv.fr/data/ban/adresses/latest/addok/addok-france-bundle.zip -O /tmp/addok-latest.zip
sudo unzip -d /opt/geocodage/addok-data /tmp/addok-latest.zip
rm /tmp/addok-latest.zip

echo "Téléchargement des docker-compose personnalisés Arcep"
sudo wget -O ./compose.yml https://raw.githubusercontent.com/ARCEP-dev/geocodage_ban/master/compose.yml
