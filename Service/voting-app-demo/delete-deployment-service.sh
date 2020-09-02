
# delete db service with name : db
kubectl delete service db

# delete redis service with name : redis
kubectl delete service redis

# delete voting-service service with name : voting-service
kubectl delete service voting-service

# delete result-service service with name : result-service
kubectl delete service result-service

# delete worker-app-deployment deployment with name : worker-app-deployment
kubectl delete deployment worker-app-deployment

# delete result-app-deployment deployment with name : result-app-deployment
kubectl delete deployment result-app-deployment

# delete voting-app-deployment deployment with name : voting-app-deployment
kubectl delete deployment voting-app-deployment

# delete postgres-deployment deployment with name : postgres-deployment
kubectl delete deployment postgres-deployment

# delete redis deployment with name : redis-deployment
kubectl delete deployment redis-deployment

# verify pods and services are deleted 
kubectl get pods,deployment,service
