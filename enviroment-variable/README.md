## Enviroment Variable - Config Map ##

- How to Pass env veriables in Docker 

```
 $ docker run -e APP_COLOR=ping simple-web-app-color
```

lets create a pod to pass the env variable APP_COLOR

'''
apiVersion: v1
kind: Pod 
metadata:
  name: simple-web-app-color
  labels:
spec:
  containers:
    - name: simple-web-app-color
      image: simple-web-app-color
      ports:
        - containerPort: 8080
      env:
        - name: APP_COLOR
          value: pink
'''

value can be pulled from **Config Map** 
- set value in pod defination file 
```
    env:
        - name: APP_COLOR
          value: pink

```
- pull value from config map 
'''
      envFrom:
        - configMapRef:
            name: app-config
'''
- pull value from secret
'''
      valueFrom:
              secretKeyRef:
                key: 

'''


## Configure a Pod to Use a ConfigMap ##
 
- ConfigMaps allow you to decouple configuration artifacts from image content to keep containerized applications portable.

- ## Create a Config Map ## 

    - Delcarative [using a configmap defination file]
        ``` 
            apiVersion: v1
            kind: ConfigMap
            metadata:
                name: app-config
            data:
                APP_COLOR: blue
                APP_MODE: prod

            kubectl create -f <<Config_File.yaml>>
        ```   

    - imperative 
        ```
            $ kubectl create configmap my-app-config --from-literal=APP_COLOR=blue --from-literal=APP_MOD=prod
            configmap/my-app-config created

            
            $ cat applcation.properties
            APP_COLOR=green
            APP_MODE=prod

            $ kubectl create configmap my-app-config-file --from-file=applcation.properties
            configmap/my-app-config-file created

        ```
        ```
             $ echo -n 'admin' > ./username.txt
             $ echo -n '1f2d1e2e67df' > ./password.txt
             $ ls -lrt
            total 12
            drwxr-xr-x 4 root root 4096 Jul  8 08:30 go
            -rw-r--r-- 1 root root    5 Aug 22 06:08 username.txt
            -rw-r--r-- 1 root root   12 Aug 22 06:09 password.txt
            
            $ kubectl create configmap sammple-app-config --from-file=username.txt --from-file=password.txt
            configmap/sammple-app-config created
            
            $ kubectl get configmaps sammple-app-config -o yaml
            apiVersion: v1
            data:
            password.txt: 1f2d1e2e67df
            username.txt: admin
            kind: ConfigMap
            metadata:
            creationTimestamp: "2020-08-22T06:10:09Z"
            managedFields:
            - apiVersion: v1
                fieldsType: FieldsV1
                fieldsV1:
                f:data:
                    .: {}
                    f:password.txt: {}
                    f:username.txt: {}
                manager: kubectl
                operation: Update
                time: "2020-08-22T06:10:09Z"
            name: sammple-app-config
            namespace: default
            resourceVersion: "1489"
            selfLink: /api/v1/namespaces/default/configmaps/sammple-app-config
            uid: 531c78a8-d8cf-43c9-9075-991ae28d6752
        ```
        lets see the cotent of config maps
        ```
             kubectl get configmaps
            NAME                 DATA   AGE
            my-app-config        2      3m25s
            my-app-config-file   1      96s
            
            $ kubectl describe configmaps my-app-config
            Name:         my-app-config
            Namespace:    default
            Labels:       <none>
            Annotations:  <none>

            Data
            ====
            APP_COLOR:
            ----
            blue
            APP_MOD:
            ----
            prod
            Events:  <none>
            
            $ kubectl describe configmaps my-app-config-file
            Name:         my-app-config-file
            Namespace:    default
            Labels:       <none>
            Annotations:  <none>

            Data
            ====
            applcation.properties:
            ----
            APP_COLOR=green
            APP_MODE=prod

            Events:  <none>

        ```
        get the YAML defination
        ```
                $ kubectl get configmaps my-app-config -o yaml
                    apiVersion: v1
                    data:
                    APP_COLOR: blue
                    APP_MOD: prod
                    kind: ConfigMap
                    metadata:
                    creationTimestamp: "2020-08-21T18:04:53Z"
                    managedFields:
                    - apiVersion: v1
                        fieldsType: FieldsV1
                        fieldsV1:
                        f:data:
                            .: {}
                            f:APP_COLOR: {}
                            f:APP_MOD: {}
                        manager: kubectl
                        operation: Update
                        time: "2020-08-21T18:04:53Z"
                    name: my-app-config
                    namespace: default
                    resourceVersion: "8670"
                    selfLink: /api/v1/namespaces/default/configmaps/my-app-config
                    uid: bbfc4467-1e79-40b8-892f-e03f5b1a375d
                
                
                 $ kubectl get configmaps my-app-config-file -o yaml
                    apiVersion: v1
                    data:
                    applcation.properties: |
                        APP_COLOR=green
                        APP_MODE=prod
                    kind: ConfigMap
                    metadata:
                    creationTimestamp: "2020-08-21T18:06:42Z"
                    managedFields:
                    - apiVersion: v1
                        fieldsType: FieldsV1
                        fieldsV1:
                        f:data:
                            .: {}
                            f:applcation.properties: {}
                        manager: kubectl
                        operation: Update
                        time: "2020-08-21T18:06:42Z"
                    name: my-app-config-file
                    namespace: default
                    resourceVersion: "8973"
                    selfLink: /api/v1/namespaces/default/configmaps/my-app-config-file
                    uid: f256c403-114e-4f5d-a5cb-6b93222d3f14
        ```


 