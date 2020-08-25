#  Deployment 

```
apiVersion: apps/v1 ## version is apps/v1
kind: Deployment
metadata:
  name: nginx-pod-deployment
  labels:
    type: front-end 
    enviroment: dev 
  
spec:
  replicas: 2
  template:
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



- **Create Deployment** 
```
$ kubectl create -f first-deployment.yml
deployment.apps/nginx-pod-deployment created
```

Deployment will create a deployment, replicaset and pods. 


- **List all the objects created post deployment creation**
```
$ kubectl get all
NAME                                        READY   STATUS              RESTARTS   AGE
pod/nginx-pod-deployment-67bdfb4846-l2vn6   0/1     ContainerCreating   0          9s
pod/nginx-pod-deployment-67bdfb4846-pvdcm   0/1     ContainerCreating   0          9s

NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   50m

NAME                                   READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx-pod-deployment   0/2     2            0           10s

NAME                                              DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-pod-deployment-67bdfb4846   2         2         0       9s
```

- **List Deployment**

```
$ kubectl get deployment
NAME                   READY   UP-TO-DATE   AVAILABLE   AGE
nginx-pod-deployment   2/2     2            2           24m
```

- **List Replica Set**
```
$ kubectl get replicaset
NAME                              DESIRED   CURRENT   READY   AGE
nginx-pod-deployment-67bdfb4846   2         2         2       24m
```

- **List Pods**
```
$ kubectl get pods
NAME                                    READY   STATUS    RESTARTS   AGE
nginx-pod-deployment-67bdfb4846-l2vn6   1/1     Running   0          24m
nginx-pod-deployment-67bdfb4846-pvdcm   1/1     Running   0          24m
```

## Lets start fresh  to see more !!! ###

- **Create a new Deployment**

```
$ cat nginx-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 4
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80

```

- **Create a new Deployment**
```
$ kubectl create -f nginx-deployment.yaml
deployment.apps/nginx-deployment created
```

- **As Soon as deployment is created run *rollout status* command**
1. This will show the current status of deployment 
2. You can see the status of each pods 
3. up on completion you see "Successfully rolled out"

```
$ kubectl rollout status deployment.apps/nginx-deployment
Waiting for deployment "nginx-deployment" rollout to finish: 0 of 4 updated replicas are available...
Waiting for deployment "nginx-deployment" rollout to finish: 1 of 4 updated replicas are available...
Waiting for deployment "nginx-deployment" rollout to finish: 2 of 4 updated replicas are available...
Waiting for deployment "nginx-deployment" rollout to finish: 3 of 4 updated replicas are available...
deployment "nginx-deployment" successfully rolled out
```

- **View the history of deployment with *rollout history* command **

```
$ kubectl rollout history  deployment.apps/nginx-deployment
deployment.apps/nginx-deployment
REVISION  CHANGE-CAUSE
1         <none>
```

Here you can seee **CHANGE-CAUSE** is empty as record is not enabled. let re-create with record enabled.

- ** create new deployment with *--record*  
```
$ kubectl create -f nginx-deployment.yaml --record
deployment.apps/nginx-deployment created
```

- **view history with *rollout history* comamnd and CHANGE-CAUSE is showing now.**    
```
$ kubectl rollout history  deployment.apps/nginx-deployment
deployment.apps/nginx-deployment
REVISION  CHANGE-CAUSE
1         kubectl create --filename=nginx-deployment.yaml --record=true
```

- **describe command will also show the *Change-Cuase* under *Annotations*** .    

*Annotations:            deployment.kubernetes.io/revision: 1*
*kubernetes.io/change-cause: kubectl create --filename=nginx-deployment.yaml --record=true*

```
$ kubectl describe  deployment.apps/nginx-deployment
Name:                   nginx-deployment
Namespace:              default
CreationTimestamp:      Fri, 14 Aug 2020 15:52:47 +0000
Labels:                 app=nginx
Annotations:            deployment.kubernetes.io/revision: 1
                        kubernetes.io/change-cause: kubectl create --filename=nginx-deployment.yaml --record=true
Selector:               app=nginx
Replicas:               4 desired | 4 updated | 4 total | 4 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=nginx
  Containers:
   nginx:
    Image:        nginx
    Port:         80/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   nginx-deployment-d46f5678b (4/4 replicas created)
Events:
  Type    Reason             Age    From                   Message
  ----    ------             ----   ----                   -------
  Normal  ScalingReplicaSet  3m28s  deployment-controller  Scaled up replica set nginx-deployment-d46f5678b to 4

```




**For other topic see here** 
- [Edit Deployment - Update Deployment via edit Deployment Command](Update-image-edit-deployment.md)
- [Edit Deployment - Update Deployment via set  Command](Update-image-set-commandy.md)
- [Rollback Deployment ](rollback-deployment.md)

**Deployment**

Create a deployment
```
kubectl create deployment --image=nginx nginx
```
Generate Deployment YAML file (-o yaml). Don't create it(--dry-run)
```
kubectl create deployment --image=nginx nginx --dry-run=client -o yaml
```
*IMPORTANT:*

kubectl create deployment does not have a --replicas option. You could first create it and then scale it using the kubectl scale command.

Save it to a file - (If you need to modify or add some other details)
```
kubectl create deployment --image=nginx nginx --dry-run=client -o yaml > nginx-deployment.yaml
```
You can then update the YAML file with the replicas or any other field before creating the deployment.
Example
```
$ kubectl create deployment --image=nginx nginx --dry-run=client -o yaml > nginx-deployment.yaml
$ cat nginx-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: nginx
  name: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: nginx
    spec:
      containers:
      - image: nginx
        name: nginx
        resources: {}
status: {}
``