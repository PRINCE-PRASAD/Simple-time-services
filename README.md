# SimpleTimeService

## Overview
SimpleTimeService is a minimalist web service that returns the current timestamp and the IP address of the visitor in JSON format. The service is containerized using Docker and can be deployed on AWS using Terraform.

## Repository Structure
```
├── app/         # SimpleTimeService application
├── terraform/   # Infrastructure as Code (IaC) using Terraform
```

## Prerequisites
- Docker
- Node.js (for local development)
- Terraform
- AWS CLI (for authentication and deployment)

---

## Running the Application
### 1. Local Setup
#### Navigate to the app directory:
```sh
cd app
```
#### Install dependencies:
```sh
npm install
```
#### Run the application using Docker:
```sh
docker run -p 3000:3000 princeprasad/simple-time-service
```
or pull the latest image and run it:
```sh
docker pull princeprasad/simple-time-service:latest
```

### 2. Expected Output
When you visit `http://localhost:3000`, you should receive a JSON response:
```json
{
  "timestamp": "2025-02-13T12:34:56Z",
  "ip": "192.168.1.1"
}
```

---

## Deploying the Infrastructure using Terraform
### 1. Navigate to the Terraform directory:
```sh
cd terraform
```
### 2. Initialize Terraform:
```sh
terraform init
```
### 3. Plan the deployment:
```sh
terraform plan
```
### 4. Apply the deployment:
```sh
terraform apply
```

---

## Authentication & Configuration for AWS Deployment
Before running Terraform commands, authenticate to AWS:
```sh
aws configure
```
