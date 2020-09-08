## Docker & Kubernetes Cofigurations##

**Docker Cofigurations**

- docker configuration can be done in 2 ways. 
1. CMD command 
2. ENTRY POINT Command 

Let's understand this by few example. 

Run an ubuntu image with sleep 10

```
$ docker container run ubuntu sleep 5
```

```
$ docker container ls -a | grep ubu
98cac7a8a2e1        ubuntu                   "sleep 5"                14 seconds ago      Exited (0) 8 seconds ago             elastic_wing
```

Here "sleep 5" command is executed once ubuntu container is started , it will exit after 5 sec.

let created an ubuntu sleep image. 

- shell form
```
FORM ubuntu

CMD sleep 5
```
OR 
```
FROM ubuntu

CMD ["sleep","5"]
```

With this we can create an ubuntu sleeper image can be run like below
```
master $ cat Dockerfile
FROM ubuntu
CMD sleep 5

$ docker build -t unbuntu-sleepr .
Sending build context to Docker daemon  180.5MB
Step 1/2 : FROM ubuntu
 ---> 74435f89ab78
Step 2/2 : CMD sleep 5
 ---> Running in a9423b52ddc0
Removing intermediate container a9423b52ddc0
 ---> 7b989e23447a
Successfully built 7b989e23447a
Successfully tagged unbuntu-sleepr:latest


$ docker run unbuntu-sleepr:latest
 $ docker container ls -a | grep unbuntu-sleepr:latest
2cdbfdf1e251        unbuntu-sleepr:latest    "/bin/sh -c 'sleep 5'"   26 seconds ago      Exited (0) 20 seconds ago              crazy_villani
```

Now this image will always sleep for 5 sec. now we can run same for 10 sec sleep as well

```
 $ docker run unbuntu-sleepr:latest sleep 10
 $ docker container ls -a | grep unbuntu-sleepr:latest
08647e01036c        unbuntu-sleepr:latest    "sleep 10"               18 seconds ago      Exited (0) 6 seconds ago              hopeful_mendel
```

- Here command at start up is "sleep 10" and this will overwtrite the CMD command in image 


What if we just like to pass 10/5/20 sec as parameter. Here EntryPoint will used.

```
$ cat Dockerfile
FROM ubuntu

ENTRYPOINT ["sleep"]

$ docker build -t unbuntu-sleepr .
Sending build context to Docker daemon  180.5MB
Step 1/2 : FROM ubuntu
 ---> 74435f89ab78Step 2/2 : ENTRYPOINT ["sleep"]
 ---> Running in e77335dd0d1eRemoving intermediate container e77335dd0d1e
 ---> b3f66a89e042
Successfully built b3f66a89e042
Successfully tagged unbuntu-sleepr:latest

$ docker run unbuntu-sleepr:latest 10

$ docker container ls -a | grep unbuntu-sleepr:latest
d227ff222a14        unbuntu-sleepr:latest    "sleep 10"               20 seconds ago      Exited (0) 9 seconds ago              frosty_goldberg
```

- here the startup command is "sleep 10" , so  10 is appened over the command mentioned in ENTRYPOINT

- Now to provide a default value to ENTRYPOINT Command. lets rebuild the image with CMD option added as well.

```
master $ cat Dockerfile
FROM ubuntu

ENTRYPOINT ["sleep"]
CMD ["5"]

$ docker build -t unbuntu-sleepr .
Sending build context to Docker daemon  180.5MB
Step 1/3 : FROM ubuntu
 ---> 74435f89ab78
Step 2/3 : ENTRYPOINT ["sleep"]
 ---> Using cache
 ---> b3f66a89e042
Step 3/3 : CMD ["5"]
 ---> Running in 7fdffd91fbc7
^[[A^[[ARemoving intermediate container 7fdffd91fbc7
 ---> 7e7a28dfa983
Successfully built 7e7a28dfa983

$ docker run --name=sleep10 unbuntu-sleepr:latest 10
$ docker run --name=sleepdefault unbuntu-sleepr:latest
$ docker container ls -a | grep unbuntu-sleepr:latest
d4171d8ea698        unbuntu-sleepr:latest    "sleep 5"                14 seconds ago      Exited (0) 8 seconds ago              sleepdefault
cf24091ef792        unbuntu-sleepr:latest    "sleep 10"               34 seconds ago      Exited (0) 22 seconds ago              sleep10

```
- Here we ran 2 containers 1 with name sleep10 and  command argument as 10 and other name as sleepdefault and no command argument
- For sleep10 container start command was "sleep 10" , that means provided value in run command is ovverride the image value 5.  
- For sleepdefault container start command was "sleep 5" with no cmd arg, that means default value provide in image is used.

let's override the ENTRYPoint instruction. 

```
$ docker run --name=overriderEP --entrypoint ls unbuntu-sleepr:latest

$ docker container ls -a | grep unbuntu-sleepr:latest
44af94b8f3d0        unbuntu-sleepr:latest    "ls"                     5 seconds ago       Exited (0) 4 seconds ago              overriderEP
```

**Conclusion**
- CMD can be overridden but supplying arguments to docker run command. 
- ENTRYPOINT will append the arguments provided in run command.
- CMD can be used with ENTRYPOINT to provide default behaviour and CMD will be appended to ENTRYPOINT
- Using --entrypoint , command given in entry point can be overriddden. 

**Apply this in Kubernates POD** 

-- let created POD defination to run below 2 docker run command. 
```
$ docker run --name=sleepdefault unbuntu-sleepr:latest

apiVersion: v1
kind: Pod
metadata:
  name: sleep-default
spec:
  containers:
    - name: sleep-default
      image: unbuntu-sleepr:latest

```

- use args to provide arguments 

```
$ docker run --name=sleep10 unbuntu-sleepr:latest 10

apiVersion: v1
kind: Pod
metadata:
  name: sleep-default

spec:
  containers:
    - name: sleep-default
      image: unbuntu-sleepr:latest
      args: ["10"]


```

- use command to override ENTRYPOINT

```
$ docker run --name=overriderEP --entrypoint ls unbuntu-sleepr:latest

apiVersion: v1
kind: Pod
metadata:
  name: sleep-default

spec:
  containers:
    - name: sleep-default
      image: unbuntu-sleepr:latest
      command: ["ls"]

```


