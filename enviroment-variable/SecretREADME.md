## Enviroment Variable - Secrets ##

**Secrets**

- Kubernetes Secrets let you store and manage sensitive information, such as passwords, OAuth tokens, and ssh keys. 
- Storing confidential information in a Secret is safer and more flexible than putting it verbatim in a Pod definition or in a container image.

- A Secret is an object that contains a small amount of sensitive data such as a password, a token, or a key. 
- Such information might otherwise be put in a Pod specification or in an image. Users can create secrets and the system also creates some secrets.

**IMP**
Secret values are stored in base 64 encoded formate. 

To use a secret, a Pod needs to reference the secret. A secret can be used with a Pod in three ways:

1. As files in a volume mounted on one or more of its containers.
2. As container environment variable.
3. By the kubelet when pulling images for the Pod.


- ## Create a Secrets ## 

- Delcarative [using a configmap defination file]
        ``` 
            apiVersion: v1
            kind: Secret
            metadata:
            name: app-secret-config
            data:
            username: cmFuZG9tZS1wYXNzd29yZAo= # base64 encoded user name 
            password: cmFuZG9tZS1wYXNzd29yZAo= # base64 encoded password

            master $ kubectl create -f simple-secret.yaml
            secret/app-secret-config created
            master $ kubectl get secrets -f simple-secret.yaml -o yaml
            error: when paths, URLs, or stdin is provided as input, you may not specify resource arguments as well
            master $ kubectl get secrets app-secret-config -o yaml
            apiVersion: v1
            data:
            password: cmFuZG9tZS1wYXNzd29yZAo=
            username: cmFuZG9tZS1wYXNzd29yZAo=
            kind: Secret
            metadata:
            creationTimestamp: "2020-08-22T06:29:26Z"
            managedFields:
            - apiVersion: v1
                fieldsType: FieldsV1
                fieldsV1:
                f:data:
                    .: {}
                    f:password: {}
                    f:username: {}
                f:type: {}
                manager: kubectl
                operation: Update
                time: "2020-08-22T06:29:26Z"
            name: app-secret-config
            namespace: default
            resourceVersion: "4504"
            selfLink: /api/v1/namespaces/default/secrets/app-secret-config
            uid: 69e8b863-4457-43c9-af99-4872ce6e878e
            type: Opaque
        ```   

- imperative 
Here are the options to create secret

        ```
        $ kubectl create secret --help
        Create a secret using specified subcommand.

        Available Commands:
        docker-registry Create a secret for use with a Docker registry
        generic         Create a secret from a local file, directory or literal value
        tls             Create a TLS secret
        ```

        **Create Secret from File**

        ```
        $ echo -n 'admin' > ./username.txt
        $ echo -n '1f2d1e2e67df' > ./password.txt

        $ kubectl create secret generic my-sample-app-secret --from-file=username.txt --from-file=password.txt
        secret/my-sample-app-secret created

        $ kubectl get secrets my-sample-app-secret -o yaml
        apiVersion: v1
        data:
        password.txt: MWYyZDFlMmU2N2Rm
        username.txt: YWRtaW4=
        kind: Secret
        metadata:
        creationTimestamp: "2020-08-22T06:14:42Z"
        managedFields:
        - apiVersion: v1
            fieldsType: FieldsV1
            fieldsV1:
            f:data:
                .: {}
                f:password.txt: {}
                f:username.txt: {}
            f:type: {}
            manager: kubectl
            operation: Update
            time: "2020-08-22T06:14:42Z"
        name: my-sample-app-secret
        namespace: default
        resourceVersion: "2258"
        selfLink: /api/v1/namespaces/default/secrets/my-sample-app-secret
        uid: a8292c5c-535e-40d7-9dda-e479d2eb71d5
        type: Opaque
        ```

        **Create Secret from literal**

        ```
        $ kubectl create secret generic my-sample-app-secret1 --from-literal=password=sameple-password
        secret/my-sample-app-secret1 created
        
        $ kubectl get secrets my-sample-app-secret -o yaml
        my-sample-app-secret   my-sample-app-secret1
        
        $ kubectl get secrets my-sample-app-secret1 -o yaml
        apiVersion: v1
        data:
        password: c2FtZXBsZS1wYXNzd29yZA==
        kind: Secret
        metadata:
        creationTimestamp: "2020-08-22T06:18:04Z"
        managedFields:
        - apiVersion: v1
            fieldsType: FieldsV1
            fieldsV1:
            f:data:
                .: {}
                f:password: {}
            f:type: {}
            manager: kubectl
            operation: Update
            time: "2020-08-22T06:18:04Z"
        name: my-sample-app-secret1
        namespace: default
        resourceVersion: "2800"
        selfLink: /api/v1/namespaces/default/secrets/my-sample-app-secret1
        uid: d77d8c18-0d80-4021-8fab-8b6d9a28621a
        type: Opaque
        ```

## Inject Secret into POD ##

```


```