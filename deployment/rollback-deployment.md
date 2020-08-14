#  Update Deployment via set Image Command 

- We will be updating the image via set command  assume a new version of application needs to be updated.
- Use docker hub to see the other official tags 

[nginx tags link](https://hub.docker.com/_/nginx?tab=description)

![alt](nginx-image-tags.JPG)

**Pre rwq**

- Use nginx-deployment.yaml  to create a new deployment.

**Create a Deployment**
```
$ kubectl create -f nginx-deployment.yaml --record
deployment.apps/nginx-deployment created
```

**List Objects created with deployment**
```
$ kubectl get all
NAME                                   READY   STATUS    RESTARTS   AGE
pod/nginx-deployment-d46f5678b-bsnpr   1/1     Running   0          12s
pod/nginx-deployment-d46f5678b-f7lb9   1/1     Running   0          12s
pod/nginx-deployment-d46f5678b-md57g   1/1     Running   0          12s
pod/nginx-deployment-d46f5678b-ngxjb   1/1     Running   0          12s

NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   53m

NAME                               READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx-deployment   4/4     4            4           12s

NAME                                         DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-deployment-d46f5678b   4         4         4       12s

```

- **see the deployment history**
```
$ kubectl rollout history deployment nginx-deployment
deployment.apps/nginx-deployment
REVISION  CHANGE-CAUSE
1         kubectl create --filename=nginx-deployment.yaml --record=true

```
- **see the current Image name**
```
$ kubectl describe  deployment.apps/nginx-deployment | grep Image
    Image:        nginx
```


- **Let's update the nginx image to nginx:1.18**

```
$ kubectl set image deployment nginx-deployment nginx=nginx:1.18 --record
deployment.apps/nginx-deployment image updated

```

- **Check the history**

$ kubectl rollout history deployment/nginx-deployment
deployment.apps/nginx-deployment
REVISION  CHANGE-CAUSE
1         <none>
2         kubectl set image deployment nginx-deployment nginx=nginx:1.18 --record=true

- **Check the deployment**
```
$ kubectl describe  deployment.apps/nginx-deployment | grep Image
    Image:        nginx:1.18
```

- **let's change the image version one more time**
```
$ kubectl set image deployment nginx-deployment nginx=nginx:1.18-alpine --record
deployment.apps/nginx-deployment image updated
```

- **Validate the History**

```
$ kubectl rollout history deployment/nginx-deployment
deployment.apps/nginx-deployment
REVISION  CHANGE-CAUSE
1         kubectl create --filename=nginx-deployment.yaml --record=true
2         kubectl set image deployment nginx-deployment nginx=nginx:1.18 --record=true
3         kubectl set image deployment nginx-deployment nginx=nginx:1.18-alpine --record=true
```

Above we can see that we have 3 revisions available and all the pods are running successful. 

- **Validate the pods status**
$ kubectl get pods
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-844d97b88b-4pd8b   1/1     Running   0          55s
nginx-deployment-844d97b88b-qklhk   1/1     Running   0          50s
nginx-deployment-844d97b88b-sjrbc   1/1     Running   0          52s
nginx-deployment-844d97b88b-vcpbp   1/1     Running   0          55s


- **Let's again update the deployment with invalid image name**
- **This is to simulate a scenario when there is an issue with provided new build** 

```
$ kubectl set image deployment nginx-deployment nginx=nginx:sumit --record
deployment.apps/nginx-deployment image updated
```

- **Validate the  history , here revision 4 is trying to update image as nginx:sumit**
```
$ kubectl rollout history deployment/nginx-deployment
deployment.apps/nginx-deployment
REVISION  CHANGE-CAUSE
1         kubectl create --filename=nginx-deployment.yaml --record=true
2         kubectl set image deployment nginx-deployment nginx=nginx:1.18 --record=true
3         kubectl set image deployment nginx-deployment nginx=nginx:1.18-alpine --record=true
4         kubectl set image deployment nginx-deployment nginx=nginx:sumit --record=true
```

- **Validate the pods status**
```
$ kubectl get pods
NAME                                READY   STATUS             RESTARTS   AGE
nginx-deployment-5d75b99c4b-47bxk   0/1     ImagePullBackOff   0          12s
nginx-deployment-5d75b99c4b-mw6tq   0/1     ErrImagePull       0          13s
nginx-deployment-844d97b88b-4pd8b   1/1     Running            0          4m18s
nginx-deployment-844d97b88b-sjrbc   1/1     Running            0          4m15s
nginx-deployment-844d97b88b-vcpbp   1/1     Running            0          4m18s
```

- **Here not all the pods are down**
- **Out of 4, 3 pods are still running with nginx version provided in revision 3**
- **While only 1 pod is trying to update the nginx Image with niginx:sumit , which is obviously going to fail**


- **let's resolve this**

