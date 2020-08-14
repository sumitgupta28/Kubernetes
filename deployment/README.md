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


** create Deployment **
```
$ kubectl create -f first-deployment.yml
deployment.apps/nginx-pod-deployment created
```

** list all the objects created post deployment creation **
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