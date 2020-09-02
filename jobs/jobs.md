# Jobs

- A Job creates one or more Pods and ensures that a specified number of them successfully terminate. 
- As pods successfully complete, the Job tracks the successful completions. 
- When a specified number of successful completions is reached, the task (ie, Job) is complete. 
- Deleting a Job will clean up the Pods it created.

    - A simple case is to create one Job object in order to reliably run one Pod to completion. The Job object will start a new Pod if the first Pod fails or is deleted (for example due to a node hardware failure or a node reboot).
    - You can also use a Job to run multiple Pods in parallel.


# Pods Behaviour:

- Pods has default restartPolicy as Always , which means kubernates will keep trying to bring pods up and running all the the times.
- since Job ( like batch) needs to be run on-demand or on a schedule basis, restartPolicy as Always will keep running the jobs again and again. while job needs to be executed only one time.
- that why jobs will have restartPolicy as Never, which helps pods to run only 1 time. 

**Simple Job example**
Here restartPolicy: Never , ensure that job runs only 1 time. 
```
apiVersion: v1 
kind: Pod 
metadata:
  name: maths-pod
spec:
  containers:
    - name: maths-pod
      image: ubuntu
      command: ['expr','3','+','2']
  restartPolicy: Never
```

**Simple Job defination example**
'''
apiVersion: batch/v1 
kind: Job
metadata:
  name: maths-add-job
spec:
  template:
    spec:
      containers:
        - name: maths-pod
          image: ubuntu
          command: ['expr','3','+','2']
      restartPolicy: Never
'''

**Create a Job and list**
- here the job creation will create 2 objects job and pod.
'''
$ kubectl create -f maths-job-defination.yaml
job.batch/maths-add-job created

$ kubectl get pods
NAME                  READY   STATUS             RESTARTS   AGE
maths-add-job-hhrcn   0/1     Completed          0          2m39s

$ kubectl get jobs
NAME            COMPLETIONS   DURATION   AGE
maths-add-job   1/1           3s         8s
'''

**Job Result**
```
$ kubectl get pod
NAME                  READY   STATUS             RESTARTS   AGE
maths-add-job-hhrcn   0/1     Completed          0          4m7s
maths-pod             0/1     CrashLoopBackOff   8          16m

$ kubectl logs -f maths-add-job-hhrcn
5
```

**Describe a Job**
```
$ kubectl describe jobs.batch maths-add-job
Name:           maths-add-job
Namespace:      default
Selector:       controller-uid=b458fe74-55f5-4f94-9002-7f8372e07823
Labels:         controller-uid=b458fe74-55f5-4f94-9002-7f8372e07823
                job-name=maths-add-job
Annotations:    <none>
Parallelism:    1
Completions:    1
Start Time:     Mon, 31 Aug 2020 03:25:58 +0000
Completed At:   Mon, 31 Aug 2020 03:26:01 +0000
Duration:       3s
Pods Statuses:  0 Running / 1 Succeeded / 0 Failed
Pod Template:
  Labels:  controller-uid=b458fe74-55f5-4f94-9002-7f8372e07823
           job-name=maths-add-job
  Containers:
   maths-pod:
    Image:      ubuntu
    Port:       <none>
    Host Port:  <none>
    Command:
      expr
      3
      +
      2
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Events:
  Type    Reason            Age   From            Message
  ----    ------            ----  ----            -------
  Normal  SuccessfulCreate  18s   job-controller  Created pod: maths-add-job-hhrcn
  Normal  Completed         15s   job-controller  Job completed
```


**Delete the Job**
 - this will also delete the the pod created by the jobs. 
```
$ kubectl delete jobs.batch  maths-add-job
```


**Pod backoff failure policy**

- There are situations where you want to fail a Job after some amount of retries due to a logical error in configuration etc. - To do so, set .spec.backoffLimit to specify the number of retries before considering a Job as failed. 
- The back-off limit is set by default to 6. 
- Failed Pods associated with the Job are recreated by the Job controller with an exponential back-off delay (10s, 20s, 40s ...) capped at six minutes. 
- The back-off count is reset when a Job's Pod is deleted or successful without any other Pods for the Job failing around that time.

**set backoffLimit**
```

```


**Running Multiple Instance Job**
- here the completions: 3 will ensure 3 pods are running for this job. 
Job Definition
```
apiVersion: batch/v1 
kind: Job
metadata:
  name: maths-add-job
spec:
  completions: 3
  template:
    spec:
      containers:
        - name: maths-pod
          image: ubuntu
          command: ['expr','3','+','2']
      restartPolicy: Never
        
```

**Create the Job and validate the output**
- By default pods are created one after another.
- Pod 2 is created once pod is created and completed. 
```
$ kubectl create -f maths-pod-job-definition-mul-instance.yaml
job.batch/maths-add-job created

$ kubectl get jobs.batch
NAME            COMPLETIONS   DURATION   AGE
maths-add-job   2/3           7s         7s

$ kubectl get pods
NAME                  READY   STATUS      RESTARTS   AGE
maths-add-job-fw5hj   0/1     Completed   0          19s
maths-add-job-jx48x   0/1     Completed   0          13s
maths-add-job-vln7f   0/1     Completed   0          16s

$ kubectl logs -f maths-add-job-fw5hj
5
$ kubectl logs -f maths-add-job-jx48x
5
$ kubectl logs -f maths-add-job-vln7f
5
```

**Jobs Paeallelism**

- inorder to create job Parallelly , add parallelism property

'''
apiVersion: batch/v1 
kind: Job
metadata:
  name: maths-add-job
spec:
  completions: 3
  parallelism: 3
  template:
    spec:
      containers:
        - name: maths-pod
          image: ubuntu
          command: ['expr','3','+','2']
      restartPolicy: Never
'''

**create a Parallel job and view instance**

'''
$ kubectl create -f maths-pod-job-definition-mul-instance-parallel.yaml
job.batch/maths-add-job created

$ kubectl get jobs.batch
NAME            COMPLETIONS   DURATION   AGE
maths-add-job   3/3           7s         7s

$ kubectl get pod
NAME                  READY   STATUS      RESTARTS   AGE
maths-add-job-4lqrz   0/1     Completed   0          19s
maths-add-job-8msfj   0/1     Completed   0          19s
maths-add-job-wxdlp   0/1     Completed   0          19s

$ kubectl describe jobs.batch maths-add-job
Name:           maths-add-job
Namespace:      default
Selector:       controller-uid=cfb9bd76-1ffb-4076-8c83-48108e90f069
Labels:         controller-uid=cfb9bd76-1ffb-4076-8c83-48108e90f069
                job-name=maths-add-job
Annotations:    <none>
Parallelism:    3
Completions:    3
Start Time:     Mon, 31 Aug 2020 03:59:53 +0000
Completed At:   Mon, 31 Aug 2020 04:00:00 +0000
Duration:       7s
Pods Statuses:  0 Running / 3 Succeeded / 0 Failed
Pod Template:
  Labels:  controller-uid=cfb9bd76-1ffb-4076-8c83-48108e90f069
           job-name=maths-add-job
  Containers:
   maths-pod:
    Image:      ubuntu
    Port:       <none>
    Host Port:  <none>
    Command:
      expr
      3
      +
      2
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Events:
  Type    Reason            Age   From            Message
  ----    ------            ----  ----            -------
  Normal  SuccessfulCreate  27s   job-controller  Created pod: maths-add-job-wxdlp
  Normal  SuccessfulCreate  27s   job-controller  Created pod: maths-add-job-4lqrz
  Normal  SuccessfulCreate  27s   job-controller  Created pod: maths-add-job-8msfj
  Normal  Completed         20s   job-controller  Job completed

'''


**Cron Job**

- A cron job is a Linux command used for scheduling tasks to be executed sometime in the future. 
- This is normally used to schedule a job that is executed periodically 
    - for example, to send out a notice every morning. Some scripts, such as Drupal and WHMCS may require you to set up cron jobs to perform certain functions.

## this definition file is to show how to create a cron job
## run --> kubectl create -f reporting-cron-job
## here schedule */1 * * * * , ensure job will run for every 1 min
```
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: reporting-cron-job
spec:
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: maths-pod
              image: ubuntu
              command: ['expr','3','+','2']
          restartPolicy: Never 
  schedule: "*/1 * * * *"
```


**Note**

1. Create job with command line 

```

Usage:
kubectl create job NAME --image=image [--from=cronjob/name] -- [COMMAND] [args...] [flags] [options]

$ kubectl create job throw-dice-job --image kodekloud/throw-dice --dry-run=client -o yaml > job.yaml

$ cat job.yaml
apiVersion: batch/v1
kind: Job
metadata:
  creationTimestamp: null
  name: throw-dice-job
spec:
  template:
    metadata:
      creationTimestamp: null
    spec:
      containers:
      - image: kodekloud/throw-dice
        name: throw-dice-job
        resources: {}
      restartPolicy: Never
status: {}

```


1. Create cron job with command line 

```
Usage:
kubectl create cronjob NAME --image=image --schedule='0/5 * * * ?' -- [COMMAND] [args...] [flags] [options]


$ kubectl create cronjob throw-dice-job --image kodekloud/throw-dice --schedule="30 21 * * *" --dry-run=client -o yaml > cronjob.yaml

$ cat cronjob.yaml
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  creationTimestamp: null
  name: throw-dice-job
spec:
  jobTemplate:
    metadata:
      creationTimestamp: null
      name: throw-dice-job
    spec:
      template:
        metadata:
          creationTimestamp: null
        spec:
          containers:
          - image: kodekloud/throw-dice
            name: throw-dice-job
            resources: {}
          restartPolicy: OnFailure
  schedule: 30 21 * * *
status: {}

```