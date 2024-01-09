# AKS Cost Opmization

 This repository aims to demonstrate ways of saving costs on your AKS clusters, leverarging the following methods:

 - Scale to Zero on Development Environments
    
    - Automating with Runbooks
        - ```./demos/runbook```
        - ```./infrastructure/automation-account.tf```

- Autoscaling

    - Horizontal Pod Autoscaler + Cluster Autoscaler
        - ```./demos/scaling```
        - ```./infrastructure/aks.tf```

- Right Sizing Pods and Nodes

    - Pod Resource requests and limits + Resource quota
        - ```./demos/quota```
        - ```./infrastructure/policy.tf```

- Spot Nodepools

    - Hot / Warm Deployment using Regular + Spot Instances (multiple deployments and hpas)
        - ```./demos/spot/hot-warm```
        - ```./infrastructure/aks```
    - Node Affinity on Spot Instances
        - ```./demos/spot/node-affinity```
        - ```./infrastructure/aks.tf```
        - ```./infrastructure/keda.tf```
        - ```./infrastructure/servicebus.tf```

## Relevant docs

https://docs.microsoft.com/en-us/learn/modules/aks-optimize-compute-costs/
https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#node-affinity
https://docs.microsoft.com/en-us/azure/aks/start-stop-cluster?tabs=azure-powershell
https://docs.microsoft.com/en-us/learn/modules/aks-optimize-compute-costs/7-exercise-resource-quota-azure-policy

## Demos

### Deploy the infrastructure

```
$ cd ./infrastructure
$ terraform init
$ terraform plan -var 'workshop_rg=<resource_group_name'
$ terraform apply
```

### Start Stop

_Azure Portal > Automation Accounts > start-stop-aks > Runbooks_ 

### Quota

Get the "development" cluster credentials and set it as the current context

```
$ az aks get-credentials --resource-group <resource_group_name> --name aks-workshop-dev
$ kubectl config use-context aks-workshop-dev
```

Apply and test the resource quota manifest

```
$ cd ./demos/quota
$ kubectl create ns dev
$ kubectl apply -f resource-quota.yaml --namespace=dev
$ kubectl get resourcequota resource-quota --namespace=dev --output=yaml
$ kubectl apply -f nginx-1.yaml --namespace=dev
$ kubectl get resourcequota resource-quota --namespace=dev --output=yaml
$ kubectl apply -f nginx-2.yaml --namespace=dev
```

### Policy

_Azure Portal > Policy > Assigned > AKS Dev Resource Limit_

Test the policy
```
$ cd ./demos/quota
$ kubectl config use-context aks-workshop-dev
$ kubectl apply -f nginx-3.yaml --namespace=default
````

### Hot Warm

Get the "production" cluster credentials and set it as the current context

```
$ az aks get-credentials --resource-group <resource_group_name> --name aks-workshop
$ kubectl config use-context aks-workshop
```

Apply Regular and Spot deployments

```
$ kubectl apply -f web-stress-spot-warm.yaml -f web-stress-spot-hot.yaml -f web-stress-service.yaml
$ watch -n 5 kubectl get pods -o wide
$ watch -n 5 kubectl get hpa
```

Run a stress test against the service endpoint 

```
kubectl run -it artillery --image=artilleryio/artillery -- quick -n 3600 -c 15 "http://web-stress-simulator/web-stress-simulator-1.0.0/cpu?time=100"
```

#### Node Affinity

Build the consumer and producer app images and push them to ACR

```
$ cd ./demos/spot/node-affinity
$ az acr build --registry <registry_name> --file Dockerfile-consumer --image order-consumer:v1 .
$ az acr build --registry <registry_name> --file Dockerfile-producer --image order-producer:v1 .
```

Get the "production" cluster credentials and set it as the current context

```
$ az aks get-credentials --resource-group <resource_group_name> --name aks-workshop
$ kubectl config use-context aks-workshop
```

Edit ```order-consumer.yaml``` and ```order-producer.yaml```, set the ```<container_registry_name>``` from the terraform output and then apply the Service Bus consumer app deployment

```
$ kubectl apply -f order-consumer.yaml
```

Start producing messages
```
$ kubectl apply -f order-producer.yaml
$ kubectl -n order scale --replicas=8 deployment/order-producer
```

Watch the consumer app deployment scale based on the queue size leveraging KEDA

```
$ watch -n 5 kubectl -n order get pods -o wide
$ kubectl -n order logs --selector app=order-consumer -f --max-log-requests 40
```

Scale spot instances to zero simulating a scenario where spot instances are unavailable and watch the deployment being allocated in regular instances

```
$ az aks nodepool update --resource-group <resource_group_name> --cluster-name aks-workshop --name spot --disable-cluster-autoscaler
$ az aks nodepool scale --resource-group <resource_group_name> --cluster-name aks-workshop --name spot --node-count 0
$ watch -n 5 kubectl -n order get pods -o wide
```

Watch the queue getting consumed again

_Azure Portal > Service Bus > aks-workshop namespace > queues > order_