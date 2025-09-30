#!/bin/bash
# filepath: jenkins-k8s-deployment/deploy-jenkins.sh

set -e

NAMESPACE=jenkins

# Create namespace if it doesn't exist
# kubectl get namespace $NAMESPACE >/dev/null 2>&1 || kubectl create namespace $NAMESPACE

# Apply Persistent Volume and Claim
kubectl apply -f persistent-volume.yaml -n $NAMESPACE
kubectl apply -f persistent-volume-claim.yaml -n $NAMESPACE

# Apply Deployment and Service
kubectl apply -f deployment.yaml -n $NAMESPACE
kubectl apply -f service.yaml -n $NAMESPACE

# Apply Ingress
kubectl apply -f ingress.yaml -n $NAMESPACE

echo "Jenkins deployment, service, ingress, and storage applied in namespace '$NAMESPACE'."