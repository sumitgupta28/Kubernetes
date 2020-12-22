# States of a Pod

*Through its lifecycle, a Pod can attain following states:*

**Pending :** The pod is accepted by the Kubernetes system but its container(s) is/are not created yet.

**Running:** The pod is scheduled on a node and all its containers are created and at-least one container is in Running state.

**Succeeded:** All container(s) in the Pod have exited with status 0 and will not be restarted.

**Failed:** All container(s) of the Pod have exited and at least one container has returned a non-zero status.

**CrashLoopBackoff:** The container fails to start and is tried again and again.


![alt](./images/pod-life-cycle.png)

- kubectl or any other API client submits the Pod spec to the API server.
- The API server writes the Pod object to the etcd data store. Once the write is successful, an acknowledgment is sent back to API server and to the client.
- The API server now reflects the change in state of etcd.
- All Kubernetes components use watches to keep checking API server for relevant changes.
- In this case, the kube-scheduler (via its watcher) sees that a new Pod object is created on API server but is not bound to any node.
- kube-scheduler assigns a node to the pod and updates the API server.
- This change is then propagated to the etcd data store. The API server also reflects this node assignment on its Pod object.
- Kubelet on every node also runs watchers who keep watching API server. Kubelet on the destination node sees that a new Pod is assigned to it.
- Kubelet starts the pod on its node by calling Docker and updates the container state back to the API server.
- The API server persists the pod state into etcd.
- Once etcd sends the acknowledgment of a successful write, the API server sends an acknowledgment back to kubelet indicating that the event is accepted.


# Pod conditions #
A Pod has a PodStatus, which has an array of PodConditions through which the Pod has or has not passed:

- PodScheduled: The Pod has been scheduled to a node.
- Initialized: All init containers have started successfully.
- ContainersReady: All containers in the Pod are ready.
- Ready: The Pod is able to serve requests and should be added to the load balancing pools of all matching Services.


lets create a pod and see the POD Conditions.
- can check the pod conditions under Conditions 
- Ready status of pods can be checked via get pod. 
```
$ kubectl run nginx-web-server --image=nginx
pod/nginx-web-server created

$ kubectl describe pod nginx-web-server | grep -A5 Conditions
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True

$ kubectl get pod
NAME               READY   STATUS    RESTARTS   AGE
nginx-web-server   1/1     Running   0          2m31s

```

# Readiness probes
- Kubernetes uses readiness probes to decide when the container is available for accepting traffic. 
- The readiness probe is used to control which pods are used as the backends for a service. 
- A pod is considered ready when all of its containers are ready. 
- If a pod is not ready, it is removed from service load balancers. 
    - For example, if a container loads a large cache at startup and takes minutes to start, you do not want to send requests to this container until it is ready, or the requests will fail—you want to route requests to other pods, which are capable of servicing requests.

Kubernetes supports three mechanisms for implementing liveness and readiness probes: 
1. running a command inside a container, 
2. making an HTTP request against a container, or 
3. opening a TCP socket against a container.

*So in short Readiness probes test ["command  / http request or Open an TCP scoket] to confirm the POD is ready to serve the traffic , as pod might take time to startup. until Test defined under Readiness probes is not successful pod is not considered as Ready*  

Examples

```
    readinessProbe: #  readiness prob with httpGet
        httpGet:
          port: 8080
          path: /api/ready
        # Number of seconds after the container has started before liveness probes are initiated. 
        initialDelaySeconds: 10
        # How often (in seconds) to perform the probe. Default to 10 seconds. Minimum value is 1.
        periodSeconds: 1
        # Minimum consecutive failures for the probe to be considered failed after having succeeded. Defaults to 3. Minimum value is 1.
        failureThreshold: 3 

    readinessProbe: # readiness prob with tcpSocket , used with database 
        tcpSocket:
          port: 3306
 
    readinessProbe: # readiness prob with Command
        exec:
          command:
            - cat
            - app/ls_ready
```

# Liveness probes

- Kubernetes uses liveness probes to know when to restart a container. 
- If a container is unresponsive—perhaps the application is deadlocked due to a multi-threading defect—restarting the container can make the application more available, despite the defect. 
- It certainly beats paging someone in the middle of the night to restart a container.

- with liveness probes, user can setup the test which runs periodically to ensure application is up and running and healthy. 
- incase if liveness probes is failed container is considered unhealthy, container with in the pod will be destroyed and re-created. 

Example 
```
    livenessProbe: #  readiness prob with httpGet
        httpGet:
          port: 8080
          path: /api/ready
        # Number of seconds after the container has started before liveness probes are initiated. 
        initialDelaySeconds: 10
        # How often (in seconds) to perform the probe. Default to 10 seconds. Minimum value is 1.
        periodSeconds: 1
        # Minimum consecutive failures for the probe to be considered failed after having succeeded. Defaults to 3. Minimum value is 1.
        failureThreshold: 3 

    livenessProbe: # readiness prob with tcpSocket , used with database 
        tcpSocket:
          port: 3306
 
    livenessProbe: # readiness prob with Command
        exec:
          command:
            - cat
            - app/ls_ready
```

# kubernetes Logs 
Run below command to see rollong logs from single container pod
```
$kubectl logs -f <<POD-Name>>
```

Run below command to see rollong logs from multi container pod

```
$kubectl logs -f <<POD-Name>> <<Container-NAME>>
```



To deploy the Metrics Server

Deploy the Metrics Server with the following command:
```
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.3.6/components.yaml
```

Verify that the metrics-server deployment is running the desired number of pods with the following command.
```
kubectl get deployment metrics-server -n kube-system
Output

NAME             READY   UP-TO-DATE   AVAILABLE   AGE
metrics-server   1/1     1            1           6m
```
