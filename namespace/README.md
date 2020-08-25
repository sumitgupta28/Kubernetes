## Namespaces ##

- Kubernetes supports multiple virtual clusters backed by the same physical cluster. These virtual clusters are called namespaces.
- Namespaces provide a scope for names. Names of resources need to be unique within a namespace, but not across namespaces. 
- Namespaces cannot be nested inside one another and each Kubernetes resource can only be in one namespace.


```
$ kubectl get namespace
NAME              STATUS   AGE
default           Active   56s
kube-node-lease   Active   57s
kube-public       Active   57s
kube-system       Active   58s
```

## Kubernetes starts with four initial namespaces: ##

- **default** The default namespace for objects with no other namespace
- **kube-system** The namespace for objects created by the Kubernetes system
- **kube-public** This namespace is created automatically and is readable by all users (including those not authenticated). 
    - This namespace is mostly reserved for cluster usage, in case that some resources should be visible and readable publicly throughout the whole cluster. 
    - The public aspect of this namespace is only a convention, not a requirement.
- **kube-node-lease** This namespace for the lease objects associated with each node which improves the performance of the node heartbeats as the cluster scales.


## Setting the namespace for a request ## 

- To set the namespace for a current request, use the --namespace flag.

For example:
```
kubectl run nginx --image=nginx --namespace=<insert-namespace-name-here>
kubectl get pods --namespace=<insert-namespace-name-here>
```

- Setting the namespace preference
You can permanently save the namespace for all subsequent kubectl commands in that context.

```
kubectl config set-context --current --namespace=<insert-namespace-name-here>
```

# Validate it
```
kubectl config view --minify | grep namespace:
```

*Kubernetes namespaces help different projects, teams, or customers to share a Kubernetes cluster.*

It does this by providing the following:

- A scope for Names.
- A mechanism to attach authorization and policy to a subsection of the cluster.
- Use of multiple namespaces is optional.

Each user community wants to be able to work in isolation from other communities. Each user community has its own:

- resources (pods, services, replication controllers, etc.)
- policies (who can or cannot perform actions in their community)
- constraints (this community is allowed this much quota, etc.)