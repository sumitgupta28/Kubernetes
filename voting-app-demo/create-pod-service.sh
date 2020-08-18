# create postgres pod with name : postgres
kubectl create -f postgres-pod.yaml

# create postgres service with name : postgres
kubectl create -f postgres-service.yaml

# create redis pod with name : redis
kubectl create -f redis-pod.yaml

# create redis service with name : redis
kubectl create -f redis-service.yaml

# create result-app-pod pod with name : result-app-pod
kubectl create -f result-app-pod.yaml

# create result-service service with name : result-service
kubectl create -f result-app-service.yaml

# create voting-app-pod pod with name : voting-app-pod
kubectl create -f voting-app-pod.yaml

# create voting-service service with name : voting-service
kubectl create -f voting-app-service.yaml

# create worker-app-pod with name : worker-app-pod
kubectl create -f worker-pod.yaml