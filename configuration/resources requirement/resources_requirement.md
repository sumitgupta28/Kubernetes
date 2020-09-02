## Managing Resources for Containers

When you specify a Pod, you can optionally specify how much of each resource a Container needs. 
The most common resources to specify are CPU and memory (RAM);

- Kubernetes scheduler decide the which node the pod goes to. 
- if node does not have sufficient memory , the schuduler avoid placing the pod in the that node. 
- if there no sufficient resource available in any of the node , kuebernates hold back scheduling the pod and result as   PENDING status with reason insufficient CPU.
- When you specify the resource request for Containers in a Pod, the scheduler uses this information to decide which node to place the Pod on. 
- When you specify a resource limit for a Container, the kubelet enforces those limits so that the running container is not allowed to use more of that resource than the limit you set. 
- The kubelet also reserves at least the request amount of that system resource specifically for that container to use.

**How Pods with resource requests are scheduled**

- When you create a Pod, the Kubernetes scheduler selects a node for the Pod to run on. 
- Each node has a maximum capacity for each of the resource types: the amount of CPU and memory it can provide for Pods. 
- The scheduler ensures that, for each resource type, the sum of the resource requests of the scheduled Containers is less than the capacity of the node. 
- Note that although actual memory or CPU resource usage on nodes is very low, the scheduler still refuses to place a Pod on a node if the capacity check fails. 
- This protects against a resource shortage on a node when resource usage later increases, for example, during a daily peak in request rate


## CPU units
The CPU resource is measured in CPU units. One CPU, in Kubernetes, is equivalent to:

1. 1 AWS vCPU
2. 1 GCP Core
3. 1 Azure vCore
4.  1 Hyperthread on a bare-metal Intel processor with Hyperthreading

Fractional values are allowed. A Container that requests 0.5 CPU is guaranteed half as much CPU as a Container that requests 1 CPU. 
You can use the suffix m to mean milli. For example 100m CPU, 100 milliCPU, and 0.1 CPU are all the same.

**The below config shows that the one container in the Pod has a CPU request of 500 milliCPU and a CPU limit of 1 CPU.**

```
resources:
  limits:
    cpu: "1"
  requests:
    cpu: 500m
```    


**If you do not specify a CPU limit**

If you do not specify a CPU limit for a Container, then one of these situations applies:

1. The Container has no upper bound on the CPU resources it can use. The Container could use all of the CPU resources available on the Node where it is running.

2. The Container is running in a namespace that has a default CPU limit, and the Container is automatically assigned the default limit. Cluster administrators can use a LimitRange to specify a default value for the CPU limit.

**Motivation for CPU requests and limits**

- By configuring the CPU requests and limits of the Containers that run in your cluster, you can make efficient use of the CPU resources available on your cluster Nodes. 
- By keeping a Pod CPU request low, you give the Pod a good chance of being scheduled. 

By having a CPU limit that is greater than the CPU request, you accomplish two things:

- The Pod can have bursts of activity where it makes use of CPU resources that happen to be available.
- The amount of CPU resources a Pod can use during a burst is limited to some reasonable amount. 


## Memory Resources

Specify a memory request and a memory limit
To specify a memory request for a Container, include the **resources:requests** field in the Container's resource manifest. 
To specify a memory limit, include **resources:limits.**

```
resources:
      limits:
        memory: "200Mi"
      requests:
        memory: "100Mi"
```


**If you do not specify a memory limit**

If you do not specify a memory limit for a Container, one of the following situations applies:

- The Container has no upper bound on the amount of memory it uses. 
- The Container could use all of the memory available on the Node where it is running which in turn could invoke the OOM Killer. 
- Further, in case of an OOM Kill, a container with no resource limits will have a greater chance of being killed.

- The Container is running in a namespace that has a default memory limit, and the Container is automatically assigned the default limit. 
- Cluster administrators can use a LimitRange to specify a default value for the memory limit.

**Motivation for memory requests and limits**

- By configuring memory requests and limits for the Containers that run in your cluster, you can make efficient use of the memory resources available on your cluster's Nodes. 
- By keeping a Pod's memory request low, you give the Pod a good chance of being scheduled. 

By having a memory limit that is greater than the memory request, you accomplish two things:
- The Pod can have bursts of activity where it makes use of memory that happens to be available.
- The amount of memory a Pod can use during a burst is limited to some reasonable amount

**Note:** 
- If a Container specifies its own memory limit, but does not specify a memory request, Kubernetes automatically assigns a memory request that matches the limit. 
- Similarly, if a Container specifies its own CPU limit, but does not specify a CPU request, Kubernetes automatically assigns a CPU request that matches the limit.


**QoS classes**
When Kubernetes creates a Pod it assigns one of these QoS classes to the Pod:

1. Guaranteed
    For a Pod to be given a QoS class of Guaranteed:
    - Every Container in the Pod must have a memory limit and a memory request, and they must be the same.
    - Every Container in the Pod must have a CPU limit and a CPU request, and they must be the same.
    ```
     resources:
      limits:
        memory: "200Mi"
        cpu: "700m"
      requests:
        memory: "200Mi"
        cpu: "700m"
     ```   

2. Burstable
    A Pod is given a QoS class of Burstable if:

    - The Pod does not meet the criteria for QoS class Guaranteed.
    - At least one Container in the Pod has a memory or CPU request.    
    ```
     resources:
      limits:
        memory: "200Mi"
      requests:
        memory: "100Mi"
    ```

3. BestEffort
    - For a Pod to be given a QoS class of BestEffort, the Containers in the Pod must not have any memory or CPU limits or requests.

    ```
        apiVersion: v1
        kind: Pod
        metadata:
        name: qos-demo-3
        namespace: qos-example
        spec:
        containers:
        - name: qos-demo-3-ctr
            image: nginx
    ```