Below is a sample Ingress YAML and step-by-step instructions to install an Ingress controller (NGINX) and expose your Jenkins service using Ingress.

1. Sample Ingress YAML

Assuming:

Your Deployment + Service (for Jenkins) already exist in namespace ci (or whatever namespace).

Service is named jenkins and listens on port 8080 (containerPort) → the Service’s port is, say, 80 or 8080.

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: jenkins-ingress
  namespace: ci
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /   # optional, if you need path rewrite
spec:
  ingressClassName: nginx   # make sure this matches your ingress controller
  rules:
  - host: jenkins.example.com   # your domain (or use a test hostname)
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: jenkins
            port:
              number: 8080


Optional: If you want TLS (HTTPS) as well:

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: jenkins-ingress
  namespace: ci
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - jenkins.example.com
    secretName: jenkins-tls-secret   # you’d create this TLS secret (crt + key)
  rules:
  - host: jenkins.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: jenkins
            port:
              number: 8080

2. Steps to Install an NGINX Ingress Controller

Here’s a typical procedure (using manifests / kubectl) to install nginx-ingress in your cluster:

Create the ingress-nginx namespace (optional / recommended)

kubectl create namespace ingress-nginx

**Add storage Class using the following steps: 
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
Then update the storageclass name in the persistent-volume-claim.yaml**

Deploy the Ingress controller manifests

Use the upstream manifests to deploy ingress-nginx. For example:

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml


This manifest will deploy the necessary controller components (deployment, service, RBAC, etc.).

(Alternatively, you can use Helm to install ingress-nginx.)

Verify the Ingress controller is running

kubectl get pods -n ingress-nginx


You should see one (or more) pods in Running status.

Check the service for Ingress controller

kubectl get svc -n ingress-nginx


Typically, ingress-nginx is exposed via a LoadBalancer (in cloud environments) or NodePort (on bare metal). You’ll get an external IP or port.

Configure DNS or hosts

If you're in a test environment, you can add an entry to your /etc/hosts mapping jenkins.example.com → external IP of ingress.

In production, set up a DNS A record pointing jenkins.example.com to the ingress controller’s external IP.

Apply your Ingress manifest

kubectl apply -f jenkins-ingress.yaml


Test access

Open your browser to http://jenkins.example.com (or https:// if TLS configured). Requests should route through ingress to your jenkins service in the ci namespace.

Notes & Tips

The ingressClassName: nginx field ties the Ingress resource to the NGINX ingress controller (if multiple ingress controllers exist).

Annotations like nginx.ingress.kubernetes.io/rewrite-target help when your service expects requests at root / or you want to strip path prefixes.

Make sure your service jenkins is reachable (ClusterIP) and its port mapping matches what the Ingress backend expects.

If using TLS, you need a Kubernetes secret containing your certificate and private key in the same namespace (or sudo/cluster-wide accessible).
