# DOCKER Security ##

Ref - [Read More here](https://pythonspeed.com/articles/root-capabilities-docker-security/)

One important part of running your container in production is locking it down, to reduce the chances of an attacker using it as a starting point to exploit your whole system. Containers are inherently less isolated than virtual machines, and so more effort is needed to secure them.

Doing this is actually pretty straightforward:

- Don’t run your container as root.
    - There are two reasons to avoid running as root, both security related.
    1. First, it means your running process will have less privileges, which means if your process is somehow remotely compromised, the attacker will have a harder time escaping the container.
    2. Running as a non-root user means you won’t try to take actions that require extra permissions. And that means you can run your container with less “capabilities”, making it even more secure.

- Run your container with less capabilities.



**Takeaways**
To have a more secure container:
1. Run as a non-root user, using the Dockerfile’s USER command.
2. Drop as many Linux capabilities as you can (ideally all of them) when you run your container.

**Solution for for #1** 

So an even better solution is adding a new user when building the image, and using the Dockerfile USER command to change the user you run as. You won’t be able to bind to ports <1024, but that’s a good thing—that’s another capability (CAP_NET_BIND_SERVICE) you don’t need. And since your container is pretty much always behind a proxy of some sort, that’s fine, the external proxy can listen on port 443 for you.

Here’s a simple Dockerfile demonstrating how this works:

```
FROM ubuntu:18.04
RUN useradd --create-home appuser
WORKDIR /home/appuser
USER appuser
```

**Other way for running docker containers with non-root user**

- usr --user command 
```
$ docker run --user=sumit ubuntu sleep 3600
```

-- add or remove capablities 
```
$ docker run --user=sumit --cap-add MAC_ADMIN ubuntu sleep 3600
$ docker run --user=sumit --cap-drop MAC_ADMIN ubuntu sleep 3600
```

## Kubernetes Security ##
- above confiration are available in Kubernetes as well. 
- This can be setup either as POD level or container level.
- if setup at POD level , its applicable to all the containers running in the pod.  
- if setup at POD & Container level , Container level setting will overide the POD level.  

see 
- [security-context-pod-level.yaml](security-context-pod-level.yaml)
- [security-context-pod-level copy.yaml](security-context-pod-level copy.yaml)


