#!/bin/bash

#!/bin/bash

# Charger les variables d'environnement depuis un fichier .env s'il existe
if [ -f .env ]; then
    set -a
    source .env
    set +a
fi

# Vérification des variables essentielles
: "${REGISTRY_USER:?Variable REGISTRY_USER non définie}"
: "${IMAGE_NAME:?Variable IMAGE_NAME non définie}"
: "${TAG:=latest}"
: "${SERVER_USER:?Variable SERVER_USER non définie}"
: "${SERVER_HOST:?Variable SERVER_HOST non définie}"
: "${CONTAINER_NAME:?Variable CONTAINER_NAME non définie}"
: "${DOCKER_PORTS:=-p 3000:3000}"
: "${DOCKER_ADDITIONAL_ARGS:=}"
: "${DOCKERFILE_PATH:?Variable DOCKERFILE_PATH non définie}"


# 1. Construire l'image Docker localement avec le nom complet
docker build -t "$REGISTRY_USER"/"$IMAGE_NAME":"$TAG" -f "$DOCKERFILE_PATH/Dockerfile" "$DOCKERFILE_PATH"

# 2. Pousser l'image sur le registre
docker push "$REGISTRY_USER"/"$IMAGE_NAME":"$TAG"

# 3. Se connecter en SSH pour déployer
ssh "${SERVER_USER}"@"${SERVER_HOST}" << EOF
    sudo -i
    # Arrêter et supprimer l'ancien conteneur s'il existe
    docker stop $CONTAINER_NAME || true
    docker rm $CONTAINER_NAME || true

    # Récupérer la nouvelle image
    docker pull $REGISTRY_USER/$IMAGE_NAME:$TAG

    # Lancer le nouveau conteneur
    docker run -d \
      --name $CONTAINER_NAME \
      $DOCKER_PORTS \
      $DOCKER_ADDITIONAL_ARGS \
      $REGISTRY_USER/$IMAGE_NAME:$TAG
      
      # Nettoyer toutes les images non utilisées
          docker image prune -a -f
EOF