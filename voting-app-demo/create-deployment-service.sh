# create postgres deployment with name : postgres-deployment
kubectl create -f postgres-deployment.yaml

# create postgres service with name : postgres
kubectl create -f postgres-service.yaml

# create redis deployment with name : redis-deployment
kubectl create -f redis-deployment.yaml

# create redis service with name : redis
kubectl create -f redis-service.yaml

# create result-app-pod deployment with name : result-app-deployment
kubectl create -f result-app-deployment.yaml

# create result-service service with name : result-service
kubectl create -f result-app-service.yaml

# create voting-app-pod deployment with name : voting-app-deployment
kubectl create -f voting-app-deployment.yaml

# create voting-service service with name : voting-service
kubectl create -f voting-app-service.yaml

# create worker-app-deployment with name : worker-app-deployment
kubectl create -f worker-deployment.yaml

# list the created pods and service
kubectl get pod,service