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
master $
```

- **Create a new Deployment**
```
$ kubectl create -f nginx-deployment.yaml
deployment.apps/nginx-deployment created
```

- **As Soon as deployment is created run <<rollout status>> command**
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

- **View the history of deployment with <<rollout history>> **

```
$ kubectl rollout history  deployment.apps/nginx-deployment
deployment.apps/nginx-deployment
REVISION  CHANGE-CAUSE
1         <none>
```