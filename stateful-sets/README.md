
# Stateless and Stateful Applications

- A stateless application is one that neither reads nor stores information about its state from one time that it is run to the next.

- A stateful application, on the other hand, can remember at least some things about its state each time that it runs.


- The key difference between stateful and stateless applications is that stateless applications don’t “store” data whereas stateful applications require backing storage

**Stateful**

Typically, stateful applications are those that care about data persistence across restarts. Additionally, they typically need started in a specific order or stopped gracefully.

**Use Cases**
- Databases
- File/Object Storage
- CMSes (WordPress, Drupal, Magento)

**Stateless**

The goal of this architecture is to have an application that can be started, stopped, deleted, remade, distributed, and run again all with minimal difference in user experience.

**Use Cases**
- Webserver 
- Static Webpages
- APIs
- Data Processing
- Rendering

# StatefulSets

- StatefulSet is the workload API object used to manage stateful applications.

- Manages the deployment and scaling of a set of Pods, and provides guarantees about the ordering and uniqueness of these Pods.

- Like a Deployment, a StatefulSet manages Pods that are based on an identical container spec.

- Unlike a Deployment, a StatefulSet maintains a sticky identity for each of their Pods.

- use storage volumes to provide persistence for your workload, you can use a StatefulSet as part of the solution.

**StatefulSets** are valuable for applications that require one or more of the following.
- Stable, unique network identifiers.
- Stable, persistent storage.
- Ordered, graceful deployment and scaling.
- Ordered, automated rolling updates.

lets create a sample stateful set and see the behaviour. 

```
apiVersion: apps/v1 ## version is apps/v1
kind: StatefulSet
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
  serviceName: nginx-service
```

After creation see all the objects created with stateful set
```
$ kubectl get all
NAME                         READY   STATUS    RESTARTS   AGE
pod/nginx-pod-deployment-0   1/1     Running   0          30s
pod/nginx-pod-deployment-1   1/1     Running   0          22s

NAME                                    READY   AGE
statefulset.apps/nginx-pod-deployment   2/2     30s
```

we can see here it created pod with stateful set name prefix (nginx-pod-deployment) and add ordinal index 0 ,1. 
also it first created index 0 and then index 1. 

let try to scale it. 

```
$ kubectl scale statefulset nginx-pod-deployment --replicas=4 --record
statefulset.apps/nginx-pod-deployment scaled

$ kubectl get pod
NAME                     READY   STATUS    RESTARTS   AGE
nginx-pod-deployment-0   1/1     Running   0          3m37s
nginx-pod-deployment-1   1/1     Running   0          3m29s
nginx-pod-deployment-2   1/1     Running   0          18s
nginx-pod-deployment-3   1/1     Running   0          15s
```

Again it created pod name with prefix and index and in order. 

Below try to scale down application and its scaled it down in reverse order [see Events for describe command ]

```
$ kubectl scale statefulset nginx-pod-deployment --replicas=2 --record
statefulset.apps/nginx-pod-deployment scaled

$ kubectl get pod
NAME                     READY   STATUS        RESTARTS   AGE
nginx-pod-deployment-0   1/1     Running       0          4m48s
nginx-pod-deployment-1   1/1     Running       0          4m40s
nginx-pod-deployment-2   0/1     Terminating   0          89s

$ kubectl get pod
NAME                     READY   STATUS    RESTARTS   AGE
nginx-pod-deployment-0   1/1     Running   0          4m50s
nginx-pod-deployment-1   1/1     Running   0          4m42s


$ kubectl describe statefulsets.apps nginx-pod-deployment
Name:               nginx-pod-deployment
Namespace:          default
CreationTimestamp:  Fri, 04 Sep 2020 03:42:29 +0000
Selector:           enviroment=dev,type=front-end
Labels:             enviroment=dev
                    type=front-end
Annotations:        kubernetes.io/change-cause: kubectl scale statefulset nginx-pod-deployment --replicas=2 --record=true
Replicas:           2 desired | 2 total
Update Strategy:    RollingUpdate
  Partition:        0
Pods Status:        2 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
  Labels:  enviroment=dev
           type=front-end
  Containers:
   nginx-containers:
    Image:        nginx
    Port:         <none>
    Host Port:    <none>
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Volume Claims:    <none>
Events:
  Type    Reason            Age    From                    Message
  ----    ------            ----   ----                    -------
  Normal  SuccessfulCreate  5m22s  statefulset-controller  create Pod nginx-pod-deployment-0 in StatefulSet nginx-pod-deployment successful
  Normal  SuccessfulCreate  5m14s  statefulset-controller  create Pod nginx-pod-deployment-1 in StatefulSet nginx-pod-deployment successful
  Normal  SuccessfulCreate  2m3s   statefulset-controller  create Pod nginx-pod-deployment-2 in StatefulSet nginx-pod-deployment successful
  Normal  SuccessfulCreate  2m     statefulset-controller  create Pod nginx-pod-deployment-3 in StatefulSet nginx-pod-deployment successful
  Normal  SuccessfulDelete  40s    statefulset-controller  delete Pod nginx-pod-deployment-3 in StatefulSet nginx-pod-deployment successful
  Normal  SuccessfulDelete  35s    statefulset-controller  delete Pod nginx-pod-deployment-2 in StatefulSet nginx-pod-deployment successful
```

Even we try to delete the a pod , due to replica set it will create new pod with same ordinal index name. 
i tried to delete nginx-pod-deployment-0 and it got deleted but soon its creating new pod with same name. 
```
$ kubectl get pod
NAME                     READY   STATUS    RESTARTS   AGE
nginx-pod-deployment-0   1/1     Running   0          9m56s
nginx-pod-deployment-1   1/1     Running   0          9m48s

$ kubectl delete pod nginx-pod-deployment-0
pod "nginx-pod-deployment-0" deleted

$ kubectl get pod
NAME                     READY   STATUS              RESTARTS   AGE
nginx-pod-deployment-0   0/1     ContainerCreating   0          3s
nginx-pod-deployment-1   1/1     Running             0          10m

```

# Headless Service

- A headless service is a service with a service IP but instead of load-balancing it will return the IPs of our associated Pods. 
- This allows us to interact directly with the Pods instead of a proxy. It's as simple as specifying None for .spec.clusterIP

Sample head less Service definition. [here clusterIP is set to none]
```
apiVersion: v1
kind: Service
metadata:
  name: my-headless-service
spec:
  clusterIP: None # <--
  selector:
    app: test-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 3000 
```



Create a deployment with 2 pods.
```
apiVersion: apps/v1 ## version is apps/v1
kind: Deployment
metadata:
  name: nginx-pod-deployment
  labels:
    type: front-end 
spec:
  replicas: 2
  template:
    metadata:
      name: nginx-pod-replica-set
      labels:
        type: front-end ## this label is given as selector  
    spec:
      containers:
        - name: nginx-containers
          image: nginx
  selector:
    matchLabels:
      type: front-end ## this label is given as selector  
```

Create a regular service
```
apiVersion: v1
kind: Service
metadata:
  name: normal-service
spec:
  selector:
    app: api
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```

And a headless service

```
apiVersion: v1
kind: Service
metadata:
  name: headless-service
spec:
  clusterIP: None # <-- Don't forget!!
  selector:
    app: api
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```

let see the services. here we don;t see CluserIp for headless service

```
$ kubectl get service
NAME               TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
headless-service   ClusterIP   None           <none>        80/TCP    18m
kubernetes         ClusterIP   10.96.0.1      <none>        443/TCP   77m
normal-service     ClusterIP   10.102.212.3   <none>        80/TCP    18m
```

let login to one of pod, install dns util

```
$ kubectl exec -it nginx-pod-deployment-67bdfb4846-b29ph -- /bin/bash
root@nginx-pod-deployment-67bdfb4846-b29ph:/# apt-get update && apt-get install -yq dnsutils && apt-get clean && rm -rf /var/lib/apt/lists
```

Perfrom dns lookup on both service

- headless-service gives 2 dns names and pod ips
- normal service just return dns name and cluster ip
```
root@nginx-pod-deployment-67bdfb4846-b29ph:/# nslookup headless-service
Server:         10.96.0.10
Address:        10.96.0.10#53

Name:   headless-service.default.svc.cluster.local
Address: 10.244.1.16
Name:   headless-service.default.svc.cluster.local
Address: 10.244.1.17


root@nginx-pod-deployment-67bdfb4846-b29ph:/# nslookup normal-service
Server:         10.96.0.10
Address:        10.96.0.10#53

Name:   normal-service.default.svc.cluster.local
Address: 10.102.212.3

root@nginx-pod-deployment-67bdfb4846-b29ph:/#

```


'''

'''