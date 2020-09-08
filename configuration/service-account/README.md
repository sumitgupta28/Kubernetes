# Service Account 


**Kubernetes distinguishes between the concept of a user account and a service account for a number of reasons:**

- User accounts are for humans. Service accounts are for processes, which run in pods.
- User accounts are intended to be global. Names must be unique across all namespaces of a cluster, future user resource will not be namespaced. Service accounts are namespaced.
- Typically, a cluster's User accounts might be synced from a corporate database, where new user account creation requires special privileges and is tied to complex business processes. 
- Service account creation is intended to be more lightweight, allowing cluster users to create service accounts for specific tasks (i.e. principle of least privilege).
- Auditing considerations for humans and service accounts may differ.
- A config bundle for a complex system may include definition of various service accounts for components of that system. Because service accounts can be created ad-hoc and have namespaced names, such config is portable.


```
$ kubectl create serviceaccount sumit
serviceaccount/sumit created

$ kubectl get serviceaccount sumit
NAME    SECRETS   AGE
sumit   1         9s

$ kubectl describe serviceaccount sumit
Name:                sumitNamespace:           default
Labels:              <none>
Annotations:         <none>
Image pull secrets:  <none>
Mountable secrets:   sumit-token-sjlmn
Tokens:              sumit-token-sjlmn
Events:              <none>

```


```

$ kubectl get secrets
NAME                  TYPE                                  DATA   AGE
default-token-nfzwl   kubernetes.io/service-account-token   3      98m
sumit-token-sjlmn     kubernetes.io/service-account-token   3      106s

$ kubectl describe secrets sumit-token-sjlmn
Name:         sumit-token-sjlmn
Namespace:    default
Labels:       <none>
Annotations:  kubernetes.io/service-account.name: sumit
              kubernetes.io/service-account.uid: d01cc057-6d49-484e-99b9-52d73761623d

Type:  kubernetes.io/service-account-token

Data
====
ca.crt:     1025 bytes
namespace:  7 bytes
token:      eyJhbGciOiJSUzI1NiIsImtpZCI6IldXb3lWcFhLQWxTYTZBbDRJMU5HaER4SHI4M0hEQThsOHJ6UHJxWmg1LTQifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6InN1bWl0LXRva2VuLXNqbG1uIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6InN1bWl0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQudWlkIjoiZDAxY2MwNTctNmQ0OS00ODRlLTk5YjktNTJkNzM3NjE2MjNkIiwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50OmRlZmF1bHQ6c3VtaXQifQ.dl0wKDcxF_y7NjJnIe4FooKsmxcfjI_rfvorOPR6p8BOaNhkXymLt0uTITrYRE7XiUIsSmyp-JVGq1dz7hQsY_M1BOD-6vw0UcnXWZ7xqv9FPnb7bewroeb8w6UOPj8LzLNfIEBs7EnMKRvjAqonUQuSvEebxdzYNuSInIW8FaolHBNtTG3Bs5M-Cc_BZKVWzMu743rBOmyX79MtVEnjalM6vFAPitQG9qGlDJj5ObalznYrN4u1qd6879RoWECMeS-5aufnzhScIwhPzYgH3QASsFG8puW0QaDKgSh39CTHv8i2Naz3fe4gZbb3uqF71GaFyG0xAoHzZspigcwnTQ

```

- This token can be used by the any application/process to make curl command to kubernetes apis. 
- if application is hosted on same cluster, token secrets can be mounted as volume in the application pod defination.



```
$ kubectl run nginx-web --image=nginx --serviceaccount=sumit

$ kubectl get pod nginx-web -o yaml > nginx-web-service-account.yaml

$ cat nginx-web-service-account.yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: "2020-08-25T05:41:28Z"
  labels:
    run: nginx-web
  managedFields:
  - apiVersion: v1
    fieldsType: FieldsV1
    fieldsV1:
      f:metadata:
        f:labels:
          .: {}
          f:run: {}
      f:spec:
        f:containers:
          k:{"name":"nginx-web"}:
            .: {}
            f:image: {}
            f:imagePullPolicy: {}
            f:name: {}
            f:resources: {}
            f:terminationMessagePath: {}
            f:terminationMessagePolicy: {}
        f:dnsPolicy: {}
        f:enableServiceLinks: {}
        f:restartPolicy: {}
        f:schedulerName: {}
        f:securityContext: {}
        f:serviceAccount: {}
        f:serviceAccountName: {}
        f:terminationGracePeriodSeconds: {}
    manager: kubectl
    operation: Update
    time: "2020-08-25T05:41:28Z"
  - apiVersion: v1
    fieldsType: FieldsV1
    fieldsV1:
      f:status:
        f:conditions:
          k:{"type":"ContainersReady"}:
            .: {}
            f:lastProbeTime: {}
            f:lastTransitionTime: {}
            f:message: {}
            f:reason: {}
            f:status: {}
            f:type: {}
          k:{"type":"Initialized"}:
            .: {}
            f:lastProbeTime: {}
            f:lastTransitionTime: {}
            f:status: {}
            f:type: {}
          k:{"type":"Ready"}:
            .: {}
            f:lastProbeTime: {}
            f:lastTransitionTime: {}
            f:message: {}
            f:reason: {}
            f:status: {}
            f:type: {}
        f:containerStatuses: {}
        f:hostIP: {}
        f:startTime: {}
    manager: kubelet
    operation: Update
    time: "2020-08-25T05:41:28Z"
  name: nginx-web
  namespace: default
  resourceVersion: "2322"
  selfLink: /api/v1/namespaces/default/pods/nginx-web
  uid: bde0a61f-e428-4f2a-9acc-f080f1366b9e
spec:
  containers:
  - image: nginx
    imagePullPolicy: Always
    name: nginx-web
    resources: {}
    terminationMessagePath: /dev/termination-log
    terminationMessagePolicy: File
    volumeMounts:
    - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
      name: sumit-token-dw6rh
      readOnly: true
  dnsPolicy: ClusterFirst
  enableServiceLinks: true
  nodeName: node01
  priority: 0
  restartPolicy: Always
  schedulerName: default-scheduler
  securityContext: {}
  serviceAccount: sumit
  serviceAccountName: sumit
  terminationGracePeriodSeconds: 30
  tolerations:
  - effect: NoExecute
    key: node.kubernetes.io/not-ready
    operator: Exists
    tolerationSeconds: 300
  - effect: NoExecute
    key: node.kubernetes.io/unreachable
    operator: Exists
    tolerationSeconds: 300
  volumes:
  - name: sumit-token-dw6rh
    secret:
      defaultMode: 420
      secretName: sumit-token-dw6rh
status:
  conditions:
  - lastProbeTime: null
    lastTransitionTime: "2020-08-25T05:41:28Z"
    status: "True"
    type: Initialized
  - lastProbeTime: null
    lastTransitionTime: "2020-08-25T05:41:28Z"
    message: 'containers with unready status: [nginx-web]'
    reason: ContainersNotReady
    status: "False"
    type: Ready
  - lastProbeTime: null
    lastTransitionTime: "2020-08-25T05:41:28Z"
    message: 'containers with unready status: [nginx-web]'
    reason: ContainersNotReady
    status: "False"
    type: ContainersReady
  - lastProbeTime: null
    lastTransitionTime: "2020-08-25T05:41:28Z"
    status: "True"
    type: PodScheduled
  containerStatuses:
  - image: nginx
    imageID: ""
    lastState: {}
    name: nginx-web
    ready: false
    restartCount: 0
    started: false
    state:
      waiting:
        reason: ContainerCreating
  hostIP: 172.17.0.8
  phase: Pending
  qosClass: BestEffort
  startTime: "2020-08-25T05:41:28Z"
```