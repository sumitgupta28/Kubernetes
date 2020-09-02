## Node Affinity

- Node affinity allows scheduling Pods to specific nodes. There are a number of use cases for node affinity, including the following:

- Spreading Pods across different availability zones to improve resilience and availability of applications in the cluster (see the image below).
- Allocating nodes for memory-intensive Pods. In this case, you can have a few nodes dedicated to less compute-intensive Pods and one or two nodes with enough CPU and RAM dedicated to memory-intensive Pods. This way you prevent undesired Pods from consuming resources dedicated to other Pods.

Inorder to add the affinity below need to be added in pod defination.   
```
$ kubectl explain pod --recursive | grep -A25 affinity

      affinity  <Object>
         nodeAffinity   <Object>
            preferredDuringSchedulingIgnoredDuringExecution     <[]Object>
               preference       <Object>
                  matchExpressions      <[]Object>
                     key        <string>
                     operator   <string>
                     values     <[]string>
                  matchFields   <[]Object>
                     key        <string>
                     operator   <string>
                     values     <[]string>
               weight   <integer>
            requiredDuringSchedulingIgnoredDuringExecution      <Object>
               nodeSelectorTerms        <[]Object>
                  matchExpressions      <[]Object>
                     key        <string>
                     operator   <string>
                     values     <[]string>
                  matchFields   <[]Object>
                     key        <string>
                     operator   <string>
                     values     <[]string>
```


One of the best features of the current affinity implementation in Kubernetes is the support for “hard” and “soft” node affinity.

- With “hard” affinity, users can set a precise rule that should be met in order for a Pod to be scheduled on a node. For example, using “hard” affinity you can tell the scheduler to run the Pod only on the node that has SSD storage attached to it.

- As the name suggests, “soft” affinity is less strict. Using “soft” affinity, you can ask the scheduler to try to run the set of Pod in availability zone XYZ, but if it’s impossible, allow some of these Pods to run in the other Availability Zone.

- **hard** node affinity is defined by the **requiredDuringSchedulingIgnoredDuringExecution** field of the PodSpec. 
- **soft** node affinity is defined by the **preferredDuringSchedulingIgnoredDuringExecution** field of the PodSpec.

**Note:**  
-  **IgnoredDuringExecution** part in both names means that if labels on a node will be changed after the Pod matching these labels is scheduled, it will still continue to run on that node.



**Example:**
```
apiVersion: v1
kind: Pod
metadata:
  name: with-node-affinity
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: kubernetes.io/e2e-az-name
            operator: In
            values:
            - e2e-az1
            - e2e-az2
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 1
        preference:
          matchExpressions:
          - key: custom-key
            operator: In
            values:
            - custom-value
  containers:
  - name: with-node-affinity
    image: k8s.gcr.io/pause:2.0
```


- As you see, the node affinity is specified under nodeAffinity field of the affinity in the PodSpec. We define “hard” and “soft” affinity rules in the same PodSpec.

- The “hard” affinity rule tells the scheduler to place the Pod only onto a node with the label whose key is kubernetes.io/e2e-az-name and the value is either e2e-az1 or e2e-az2 .

- The “soft” rule says that among the nodes that meet “hard” criteria, we prefer the Pod to be placed on the nodes that have a label with the key custom-key and value custom-value. Because this rule is “soft,” if there are no such nodes, the Pod will still be scheduled if the “hard” rule is met.



## Inter-Pod Affinity/Anti-Affinity

With **Inter-Pod affinity/anti-affinity**, you can define whether a given Pod should or should not be scheduled onto a particular node based on labels of other Pods already running on that node.



There are a number of use cases for Pod Affinity, including the following:

- Co-locate the Pods from a particular service or Job in the same availability zone.
- Co-locate the Pods from two services dependent on each other on one node to reduce network latency between them. 
- Co-location might mean same nodes and/or same availability zone.

In its turn, Pod anti-affinity is typically used for the following use cases:

- Spread the Pods of a service across nodes and/or availability zones to reduce correlated failures. 
- For example, we may want to prevent data Pods of some database (e.g., Elasticsearch) to live on the same node to avoid the single point of failure.
- Give a Pod “exclusive” access to a node to guarantee resource isolation.
- Don’t schedule the Pods of a particular service on the same nodes as Pods of another service that may interfere with the performance of the Pods of the first service.


The Pod affinity/anti-affinity may be formalized as follows. 

*this Pod should or should not run in an X node if that X node is already running one or more pods that meet rule Y*
- Y is a LabelSelector of Pods running on that node.
- X may be a node, rack, CSP region, CSP zone, etc. Users can express it using a topologyKey .


Similarly to node affinity, Pod affinity and anti-affinity support “hard” and “soft” rules. Inter-pod affinity is specified under the field affinity.podAffinity of the PodSpec. And inter-pod anti-affinity is specified under affinity.podAntiAffinity in the PodSpec.

**Example**

```
apiVersion: v1
kind: Pod
metadata:
  name: with-pod-affinity
spec:
  affinity:
    podAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: security
            operator: In
            values:
            - S1
        topologyKey: failure-domain.beta.kubernetes.io/zone
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchExpressions:
            - key: security
              operator: In
              values:
              - S2
          topologyKey: kubernetes.io/hostname
  containers:
  - name: with-pod-affinity
    image: k8s.gcr.io/pause:2.0

```

## lets validate this.. 

**Configuring Pod Anti-Affinity**

first define the first Pod against which we’ll later create the anti-affinity rule:
```
apiVersion: v1
kind: Pod
metadata:
  name: s1
  labels:
    security: s1
spec:
  containers:
  - name: bear
    image: supergiantkir/animals:bear
```

let’s create the second Pod with the Pod anti-affinity rule:
```
apiVersion: v1
kind: Pod
metadata:
  name: pod-s2
spec:
  affinity:
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: security
            operator: In
            values:
            - s1
        topologyKey: kubernetes.io/hostname
  containers:
  - name: pod-antiaffinity
    image: supergiantkir/animals:hare
```

we specified the labelSelector “security:s1” under spec.affinity.podAntiAffinity . That’s why the second Pod won’t be scheduled to any node that has a Pod with a label security:s1 running on it.

```
$ kubectl get nodes
NAME           STATUS   ROLES    AGE   VERSION
controlplane   Ready    master   77m   v1.18.0
node01         Ready    <none>   77m   v1.18.0

$ kubectl get pod -o wide
NAME     READY   STATUS    RESTARTS   AGE    IP           NODE     NOMINATED NODE   READINESS GATES
pod-s2   0/1     Pending   0          40s    <none>       <none>   <none>           <none>
s1       1/1     Running   0          102s   10.244.1.4   node01   <none>           <none>
```

Here pod-s2 is in pending status , as we have only one node and it has running an pod s1 with label security: s1.

**Configuring Pod Affinity**

Redefine the pod-s2 defination. here podAffinity says , run pod-s2 where a pod already running with lable security and values in s1.

```
apiVersion: v1
kind: Pod
metadata:
  name: pod-s2
spec:
  affinity:
    podAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: security
            operator: In
            values:
            - s1
```

For more details [Click here](https://medium.com/kubernetes-tutorials/learn-how-to-assign-pods-to-nodes-in-kubernetes-using-nodeselector-and-affinity-features-e62c437f3cf8)