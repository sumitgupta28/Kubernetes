## Assigning Pods to Nodes

- You can constrain a Pod to only be able to run on particular Node(s), or to prefer to run on particular nodes. 
- There are several ways to do this, and the recommended approaches all use **label selectors** to make the selection.    
- Generally such constraints are unnecessary, as the scheduler will automatically do a reasonable placement (e.g. spread your pods across nodes, not place the pod on a node with insufficient free resources, etc.) but there are some circumstances where you may want more control on a node where a pod lands, for example to ensure that a pod ends up on a machine with an SSD attached to it, or to co-locate pods from two different services that communicate a lot into the same availability zone.

**nodeSelector**

There are some scenarios when you want your Pods to end up on specific nodes. For example:
- You want your Pod(s) to end up on a machine with the SSD attached to it.
- You want to co-locate Pods on a particular machine(s) from the same availability zone.
- You want to co-locate a Pod from one Service with a Pod from another service on the same node because these Services strongly depend on each other. 
- For example, you may want to place a web server on the same node as the in-memory cache store like Memcached

These scenarios are addressed by a number of primitives in Kubernetes:

- **nodeSelector** — This is a simple Pod scheduling feature that allows scheduling a Pod onto a node whose labels match the nodeSelector labels specified by the user.

- **Node Affinity** — This is the enhanced version of the nodeSelector introduced in Kubernetes 1.4 in beta. It offers a more expressive syntax for fine-grained control of how Pods are scheduled to specific nodes.

- **Inter-Pod Affinity** — This feature addresses the third scenario above. Inter-Pod affinity allows co-location by scheduling Pods onto nodes that already have specific Pods running.

**NodeSelector**
- nodeSelector is the simplest recommended form of node selection constraint. 
- nodeSelector is a field of PodSpec. 
- It specifies a map of key-value pairs. 
- For the pod to be eligible to run on a node, the node must have each of the indicated key-value pairs as labels (it can have additional labels as well). 
- The most common usage is one key-value pair.





Applying nodeSelector to the Pod involves several steps. We first need to assign a label to some node that will be later used by the nodeSelector .

```

$ kubectl get nodes --show-labels

NAME           STATUS   ROLES    AGE   VERSION   LABELS
controlplane   Ready    master   36m   v1.18.0   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=controlplane,kubernetes.io/os=linux,node-role.kubernetes.io/master=

node01         Ready    <none>   36m   v1.18.0   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=node01,kubernetes.io/os=linux

```

Next, select a node to which you want to add a label.
```
$ kubectl label nodes node01 disktype=ssd
node/node01 labeled

$ kubectl get nodes node01 --show-labels
NAME     STATUS   ROLES    AGE   VERSION   LABELS
node01   Ready    <none>   38m   v1.18.0   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,disktype=ssd,kubernetes.io/arch=amd64,kubernetes.io/hostname=node01,kubernetes.io/os=linux



$ kubectl describe node node01
Name:               node01
Roles:              <none>
Labels:             beta.kubernetes.io/arch=amd64
                    beta.kubernetes.io/os=linux
                    disktype=ssd
                    kubernetes.io/arch=amd64
                    kubernetes.io/hostname=node01
                    kubernetes.io/os=linux
```


In order to assign a Pod to the node with the label we just added, you need to specify a nodeSelector field in the PodSpec. You can have a manifest that looks something like this:

```
apiVersion: v1
kind: Pod
metadata:
  name: httpd
  labels:
    env: prod
spec:
  containers:
  - name: httpd
    image: httpd
    imagePullPolicy: IfNotPresent
  nodeSelector:
    disktype: ssd
```    

Create the pod. 

```
$ kubectl create -f node-selector-pod.yaml
pod/httpd created

$ kubectl get pods -o wide
NAME    READY   STATUS    RESTARTS   AGE   IP           NODE     NOMINATED NODE   READINESS GATES
httpd   1/1     Running   0          14s   10.244.1.3   node01   <none>           <none>
```

Here we can see the pod httpd is running on node01.



**Node Selector Limitation** 
- Node Selector , use the node lable to place the node but it can't have expression like AND/OR/NOT combinations 
    - like lable X OR label Y.
    - NOT lable Z. 