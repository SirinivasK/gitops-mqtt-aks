# Deploying MQTT Broker on AKS with Terraform, Helm, and Argo CD

This guide provides step-by-step instructions on deploying an MQTT broker within an AKS cluster, leveraging Terraform for infrastructure provisioning, Helm for application deployment, and Argo CD for continuous deployment.

## Prerequisites

- Azure CLI
- Terraform
- kubectl
- Helm
- Argo CD CLI
- Git

Ensure you have configured the Azure CLI and have permissions to create resources within your Azure subscription.

## 1. Setting Up AKS Cluster with Terraform

**1.1 Initialize Terraform Workspace**

Create a directory for your Terraform configuration.

```bash
mkdir terraform-aks && cd terraform-aks
```

**1.2 Create `main.tf`**

Add the following Terraform configuration to provision an AKS cluster. Replace placeholders with appropriate values.

```hcl
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "aks" {
  name     = "<RESOURCE_GROUP_NAME>"
  location = "East US"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "<CLUSTER_NAME>"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = "<DNS_PREFIX>"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}
```

**1.3 Apply Configuration**

Initialize and apply your Terraform configuration.

```bash
terraform init
terraform apply
```

## 2. Deploying MQTT Broker with Helm and Argo CD

### Helm Chart Preparation

**2.1 Creating Helm Chart**

Navigate to your project directory and create a Helm chart for the MQTT broker.

```bash
helm create mqtt-broker
```

**2.2 Configuring Helm Chart**

Modify the `values.yaml`, `deployment.yaml`, and other relevant files within the `mqtt-broker` Helm chart to fit the MQTT broker deployment specifications.

**`values.yaml` Example**

```yaml
mqttBroker:
  image: eclipse-mosquitto:latest
  ports:
    - name: mqtt
      port: 1883
      targetPort: 1883
```

**Deployment Configuration**

Adjust `templates/deployment.yaml` based on your specific requirements for the MQTT broker.

**Service Configuration**

Create a `service.yaml` under `templates` to expose the MQTT broker.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mqtt-broker
spec:
  type: LoadBalancer
  ports:
    - port: 1883
      targetPort: 1883
      protocol: TCP
  selector:
    app: mqtt-broker
```

### Argo CD Setup and Application Deployment

**2.3 Installing Argo CD**

Install Argo CD in your AKS cluster.

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

**2.4 Registering AKS Cluster with Argo CD**

Use the Argo CD CLI to register your AKS cluster.

```bash
argocd cluster add <CONTEXT_NAME> --upsert
```

**2.5 Deploying Application with Argo CD**

Create an Argo CD application manifest (`mqtt-broker-app.yaml`) to deploy the MQTT broker.

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: mqtt-broker
  namespace: argocd
spec:
  project: default
  source:
    repoURL: 'https://github.com/<your-username>/<your-repo>.git'
    path: mqtt-broker
    targetRevision: HEAD
  destination:
    server: 'https://kubernetes.default.svc'
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

Apply the application manifest using kubectl or the Argo CD CLI.

```bash
kubectl apply -f mqtt-broker-app.yaml
# Or
argocd app create -f mqtt-broker-app.yaml
```

### Git Workflow

**2.6 Pushing Changes**

Commit and push your Helm chart and any other Kubernetes manifests to your Git repository.

```bash
git add .
git commit

 -m "Add MQTT broker Helm chart and Argo CD app manifest"
git push
```

## 3. Accessing MQTT Broker

Once deployed, access the MQTT broker externally using the LoadBalancer IP.

```bash
kubectl get svc
```

Look for the `mqtt-broker` service and use its external IP to connect to the MQTT broker.

## Troubleshooting

- **Deployment Failures**: Check pod logs, describe pods, and services for error messages.
- **Argo CD Sync Issues**: Use `argocd app list` and `argocd app sync <APP_NAME>` to manage sync states.
- **Service Exposure**: Verify LoadBalancer IP allocation and port configurations.

## Conclusion

This guide provides a comprehensive walkthrough of deploying an MQTT broker on AKS using Terraform for infrastructure, Helm for application deployment, and Argo CD for continuous deployment management. Each step includes command-line examples and template snippets to assist in the setup process.