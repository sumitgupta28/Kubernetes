# delete worker-app-pod with name : worker-app-pod
kubectl delete pod worker-app-pod

# delete voting-service service with name : voting-service
kubectl delete service voting-service

# delete result-service service with name : result-service
kubectl delete service result-service

# delete result-app-pod pod with name : result-app-pod
kubectl delete pod result-app-pod

# delete voting-app-pod pod with name : voting-app-pod
kubectl delete pod voting-app-pod

# delete postgres pod with name : postgres
kubectl delete pod postgres

# delete postgres service with name : postgres
kubectl delete service db

# delete redis service with name : redis
kubectl delete service redis

# delete redis pod with name : redis
kubectl delete pod redis

# verify pods and services are deleted 
kubectl get pod,service
