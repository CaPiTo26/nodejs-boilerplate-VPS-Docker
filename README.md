# Node.js Boilerplate Deployable on VPS with Docker

This repository serves as a boilerplate to deploy a Node.js application on a Virtual Private Server (VPS) configured
with Docker. It provides a streamlined setup for containerizing and deploying your Node.js project with ease.

## Prerequisites

Before proceeding with the deployment, ensure that the following prerequisites are met:

1. **VPS Configuration**:
    - Your VPS must have Docker installed and running.
    - Both the client and server sides must be synchronized with `docker login`. This ensures access to Docker Hub or
      any private Docker registry you are using.

   ```bash
   # Login to Docker on the VPS (run as the user deploying the containers)
   docker login
   ```

2. **Local Environment**:
    - Docker must also be installed and the CLI configured locally, as the `deploy.sh` script uses Docker commands to
      build and push the container to the registry.

3. **Node.js Application**:
    - The boilerplate assumes your Node.js application resides in this repository, and the entry point of the
      application is specified in the `Dockerfile`.

---

## File Overview

### `deploy.sh`

A shell script designed to automate the process of building, tagging, pushing the container image, and deploying it on
the VPS.

```bash
#!/bin/bash
# Step 1: Docker Build
echo "Building the Docker image..."
docker build -t $IMAGE_NAME:$TAG .

# Step 2: Docker Push
echo "Pushing the Docker image to Docker Hub..."
docker push $IMAGE_NAME:$TAG

# Step 3: SSH into VPS and pull the updated image
echo "Deploying to VPS..."
ssh $REMOTE_VPS << EOF
  docker pull $IMAGE_NAME:$TAG
  docker stop $IMAGE_NAME || true
  docker rm $IMAGE_NAME || true
  docker run -d --name $IMAGE_NAME -p 80:3000 $IMAGE_NAME:$TAG
EOF

echo "Deployment completed successfully!"
```

#### Notes:

- Replace placeholders with your values on a .env file (See ```.env.example```).
- Ensure you have SSH access set up to the VPS and permissions to manage Docker.

---

### `Dockerfile`

The `Dockerfile` is used to containerize the Node.js application. This boilerplate assumes a typical Node.js application
structure.

```dockerfile
# Base image
FROM node:18

# Set Working Directory
WORKDIR /usr/src/app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install --production

# Copy application code
COPY . .

# Expose the application port
EXPOSE 3000

# Run the application
CMD ["npm", "start"]
```

#### Notes:

- Replace `3000` with the port your Node.js application runs on if needed.
- Ensure the entry point script of your application is defined in the `package.json` file (e.g.,
  `"start": "node index.js"`).

---

## Deployment Instructions

1. Clone the repository to your local machine:
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. Ensure the prerequisites are met (Docker installed and logged in, SSH access to VPS configured).

3. Make the `deploy.sh` script executable:
   ```bash
   chmod +x deploy.sh
   ```

4. Run the `deploy.sh` script:
   ```bash
   ./deploy.sh
   ```

   This script will:
    - Build the Docker container for the Node.js application.
    - Push the container image to Docker Hub (or another Docker registry).
    - SSH into the VPS, pull the updated image, and restart the container.

5. Access the application using the VPS's IP address:
   ```bash
   http://<your-vps-ip>
   ```

   > **Note**: Root access to the VPS is required for deployment. Ensure you have configured SSH with an RSA key for
   secure access. Otherwise, check deploy.sh and modify ```sudo -i```
---

## Customization

- You can configure environment variables in the container by modifying the `docker run` command within the `deploy.sh`
  script, for example:
  ```bash
  docker run -d --name $IMAGE_NAME -p 80:3000 -e NODE_ENV=production $IMAGE_NAME:$TAG
  ```

- For persistent data, consider mounting volumes to the container:
  ```bash
  docker run -d --name $IMAGE_NAME -p 80:3000 -v /path/on/vps:/usr/src/app/data $IMAGE_NAME:$TAG
  ```

- The `deploy.sh` script includes a cleanup step (```docker image prune -a -f```) at the end of the process that removes all Docker images except the one
  used by the running container. If you do not want this behavior, you can delete or comment out the corresponding line
  in the script.

---

## Troubleshooting

- **Docker Login Issues**: Ensure you are logged in to Docker on both your local machine and the VPS.
- **SSH Configuration**: Verify that the SSH key is correctly configured for access to the VPS.
- **Image Pull Errors on VPS**: Confirm that the VPS has internet access and can connect to the Docker registry.
- **Port Conflicts**: If port `80` is already in use, you can specify a different host port in the `docker run` command.
- **Container Status**: Check the state of the container using `docker ps` or `docker ps -a` and verify the images with
  `docker images` on the VPS.
- **Firewall Rules**: Ensure that the port being used is allowed (e.g., `ufw allow 3000`).

---

## Conclusion

This boilerplate simplifies the process of deploying a Node.js application to a Docker-enabled VPS. Customize the
scripts and configurations as needed for your specific use case. Happy coding! 🚀