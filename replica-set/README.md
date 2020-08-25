# ReplicationController #

- A ReplicationController ensures that a specified number of pod replicas are running at any one time. 
- In other words, a ReplicationController makes sure that a pod or a homogeneous set of pods is always up and available.
- Each replication controller has a desired state that is managed by the application deployer. 
- When a change is made to the desired state, a reconciliation loop detects this and attempts to mutate the existing state in order to match  the desired state. 
- For example, if you increase the desired instance count from 3 to 4, the replication controller would see that one new instance needs to be created and launch it somewhere on the cluster. This reconciliation process applies to any modified property of the pod template.

![alt](./images/controller.svg)

Here's an example replication controller definition:
```
apiVersion: v1
kind: ReplicationController
metadata:
  name: nginx-controller
spec:
  replicas: 2
  selector:
    role: load-balancer
  template:
    metadata:
      labels:
        role: load-balancer
    spec:
      containers:
        - name: nginx
          image: coreos/nginx
          ports:
            - containerPort: 80
```
# Replica Set #
```
apiVersion: apps/v1 ## version is apps/v1
kind: ReplicaSet
## metadata for ReplicaSet
metadata:
  name: nginx-pod-replica-set
  labels:
    type: front-end 
    enviroment: dev 
  
spec:
  replicas: 2
  template:
    ## metadata for Pod
    metadata:
      name: nginx-pod-replica-set
      labels:
        type: front-end ## this label is given as selector  
        enviroment: dev 
    spec:
      containers:
        - name: nginx-containers
          image: nginx
  selector:
    matchLabels:
      type: front-end ## this label is given as selector  
      enviroment: dev
```

# Replica set vs replication controller #

- Replica set and replication controller - Both the terms have the word replica.  
- There are multiple ways your container can crash. Replication is used for the core purpose of Reliability, Load Balancing, and Scaling.

- The **Replication controller** makes sure that few pre-defined pods always exist. So in case of a pod crashes, the replication controller replaces it.

- The **Replica set** defination has an extra field of selector. there selector allows the manage the older pods which has matching lable or matching expression.   

```
selector:
     matchLabels:
       app: example
----------
selector:
     matchExpressions:
      - {key: app, operator: In, values: [example, example, rs]}
      - {key: teir, operator: NotIn, values: [production]}
```      


# scale the replicaSet #
# Option 1 #
-  update the replica set defination file 
-  run -> 
  kubectl replace -f replica-set.yaml       

# Option 2 #
- run below command (assume we have a replica set with name "nginx-pod-replica-set") 
```
  kubectl scale --replicas=6 replicaset nginx-pod-replica-set
```
- this command will not update the nginx-pod-replica-set defination.          

# Option 3 #
- run below command (assume we have a replica set with name "nginx-pod-replica-set" and yaml file is nginx-pod-replica-set.yaml) 
- this won't update the replica set defination yaml 
```
  kubectl scale --replicas=6 replicaset -f nginx-pod-replica-set.yaml
```

# Delete the replica set
- run --> 
```
kubectl delete replicaset nginx-pod-replica-set
```