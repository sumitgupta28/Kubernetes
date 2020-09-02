## Taints and Tolerations

**Affinity and anti-affinity** 
- NodeSelector provides a very simple way to constrain pods to nodes with particular labels. The affinity/anti-affinity feature, greatly expands the types of constraints you can express. 

The key enhancements are

- The affinity/anti-affinity language is more expressive. The language offers more matching rules besides exact matches created with a logical AND operation;
- You can indicate that the rule is "soft"/"preference" rather than a hard requirement, so if the scheduler can't satisfy it, the pod will still be scheduled;
- You can constrain against labels on other pods running on the node (or other topological domain), rather than against labels on the node itself, which allows rules about which pods can and cannot be co-located
- The affinity feature consists of two types of affinity, "node affinity" and "inter-pod affinity/anti-affinity". Node affinity is like the existing nodeSelector (but with the first two benefits listed above), while inter-pod affinity/anti-affinity constrains against pod labels rather than node labels, as described in the third item listed above, in addition to having the first and second properties listed above.

**Node affinity**
Node affinity is conceptually similar to nodeSelector -- it allows you to constrain which nodes your pod is eligible to be scheduled on, based on labels on the node.


**Node affinity**, is a property of Pods that attracts them to a set of nodes (either as a preference or a hard requirement). **Taints** are the opposite -- they allow a node to repel a set of pods.
**Tolerations** are applied to pods, and allow (but do not require) the pods to schedule onto nodes with matching taints.

*Taints* - Applied on Node
*Tolerations* - Applied on POD

## Concepts

You add a taint to a node using kubectl taint. 

There are 3 taint effects
1. NoSchedule - POD won;t be schedule on node. 
2. PreferNoSchedule - Schedule will try to avoid the node on the pod but thats not guaranteed 
3. NoExecute - New PoD will not be sceduled on the node and existing pods will be evicated if they do not tolerat the taint.

For example,
```
kubectl taint nodes node1 key=value:NoSchedule
```

The taint has key key, value value, and taint effect NoSchedule. This means that no pod will be able to schedule onto node1 unless it has a matching toleration.

To remove the taint added by the command above, you can run:
```
kubectl taint nodes node1 key:NoSchedule-
```

You specify a toleration for a pod in the PodSpec. 
Both of the following tolerations "match" the taint created by the kubectl taint line above, and thus a pod with either toleration would be able to schedule onto node1:
```
tolerations:
- key: "key"
  operator: "Equal"
  value: "value"
  effect: "NoSchedule"
```

```
tolerations:
- key: "key"
  operator: "Exists"
  effect: "NoSchedule"
```  

The default value for operator is Equal.

A toleration "matches" a taint if the keys are the same and the effects are the same, and:
- the operator is Exists (in which case no value should be specified), or
- the operator is Equal and the values are equal.

**Taints and Tolerations** 
- Are only maint to restrict the nodes from accepting certain pods.
- it does tell pods to go perrticuler node but instead it tell nodes to accept pods with certrainer Tolerations. 
- Kubernetes scheduler does not palce any pods on clusters master nodes , because when we setup a master node it puts a taint on master node automatically and which prevent from pods schedule. 

**Note:**
There are two special cases:

1. An empty key with operator Exists matches all keys, values and effects which means this will tolerate everything.
2. An empty effect matches all effects with key key.


## Example Use Cases ## 
Taints and tolerations are a flexible way to steer pods away from nodes or evict pods that shouldn't be running. A few of the use cases are

- **Dedicated Nodes** 
    - If you want to dedicate a set of nodes for exclusive use by a particular set of users, you can add a taint to those nodes (say, kubectl taint nodes nodename dedicated=groupName:NoSchedule) and then add a corresponding toleration to their pods (this would be done most easily by writing a custom admission controller). 
    - The pods with the tolerations will then be allowed to use the tainted (dedicated) nodes as well as any other nodes in the cluster. 
    - If you want to dedicate the nodes to them and ensure they only use the dedicated nodes, then you should additionally add a label similar to the taint to the same set of nodes (e.g. dedicated=groupName), and the admission controller should additionally add a node affinity to require that the pods can only schedule onto nodes labeled with dedicated=groupName.

**Nodes with Special Hardware**
    -  In a cluster where a small subset of nodes have specialized hardware (for example GPUs), it is desirable to keep pods that don't need the specialized hardware off of those nodes, thus leaving room for later-arriving pods that do need the specialized hardware. 
    - This can be done by tainting the nodes that have the specialized hardware (e.g. kubectl taint nodes nodename special=true:NoSchedule or kubectl taint nodes nodename special=true:PreferNoSchedule) and adding a corresponding toleration to pods that use the special hardware. 

**Taint based Evictions** 
    - A per-pod-configurable eviction behavior when there are node problems.