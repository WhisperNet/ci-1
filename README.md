# CI/CD Pipeline with Jenkins

This repository contains a complete CI/CD pipeline setup using Jenkins that builds, tests, packages, and deploys a Node.js "Hello World" web application.

## Project Structure

```
ci-1/
├── app/
│   ├── index.js              # Express.js web server
│   ├── package.json          # Node.js dependencies
│   └── test/
│       └── index.test.js     # Jest unit tests
├── Dockerfile                # Multi-stage Docker build
├── docker-compose.yml        # Application deployment
├── docker-compose.jenkins.yml # Jenkins with Docker-in-Docker
├── Jenkinsfile               # Declarative Jenkins pipeline
├── healthcheck.sh            # Health verification script
├── .dockerignore
├── .gitignore
└── README.md
```

## Application

The demo application is a simple Express.js server that:

- Serves "Hello World" on the root endpoint (`/`)
- Provides a health check endpoint (`/health`) returning JSON status
- Runs on port 3000

## Prerequisites

- Docker and Docker Compose installed
- Jenkins (can be run via Docker Compose - see below)
- Git

## Quick Start

### Option 1: Run Jenkins in Docker (Docker-in-Docker)

1. Start Jenkins and the application:

   ```bash
   docker-compose -f docker-compose.jenkins.yml up -d
   ```

2. Get Jenkins initial admin password:

   ```bash
   docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
   ```

3. Access Jenkins at `http://localhost:8080` and complete setup

4. Install required Jenkins plugins:

   - Docker Pipeline
   - Docker plugin

5. Create a new Pipeline job in Jenkins:

   - Select "Pipeline script from SCM"
   - Set SCM to Git
   - Repository URL: path to this repository
   - Script Path: `Jenkinsfile`

6. Run the pipeline

### Option 2: Use Existing Jenkins Installation

1. Ensure Docker and Docker Compose are available to Jenkins

2. Create a new Pipeline job:

   - Select "Pipeline script from SCM"
   - Set SCM to Git
   - Repository URL: path to this repository
   - Script Path: `Jenkinsfile`

3. Run the pipeline

### Manual Deployment (Without Jenkins)

1. Build and run the application:

   ```bash
   docker-compose up -d
   ```

2. Check health:

   ```bash
   ./healthcheck.sh
   ```

3. Access the application:
   - Root: `http://localhost:3000`
   - Health: `http://localhost:3000/health`

## Pipeline Stages

The Jenkins pipeline includes the following stages:

1. **Build**: Installs Node.js dependencies
2. **Test**: Runs Jest unit tests
3. **Package**: Builds Docker image
4. **Deploy**: Deploys using Docker Compose
5. **Health Check**: Verifies container is running and healthy

## Health Check

The health check script (`healthcheck.sh`) verifies:

- Container is running
- `/health` endpoint responds with status 200
- Health endpoint returns valid JSON

## Testing

Run tests locally:

```bash
cd app
npm install
npm test
```

## Stopping Services

Stop all services:

```bash
docker-compose down
# or for Jenkins setup:
docker-compose -f docker-compose.jenkins.yml down
```

## Notes

- The Jenkins container requires Docker socket access for Docker-in-Docker
- Jenkins data is persisted in a Docker volume
- The application container includes built-in health checks
- All Docker images use Alpine Linux for minimal size
