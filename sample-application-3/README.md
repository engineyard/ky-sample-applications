# KontainerYard example-application-3: multi pod application with autoscaling

A Rails application created to test sidekiq workers, cron jobs and database migrations on KY.

# Introduction

A real KontainerYard application will consist of multiple processes each one having its own pod/s. Some processes are "special" like `cronenberg` and `migration`, while others like `web` and `sidekiq` are not. 

### cronenberg
The `cronenberg` process is a pod that will execute our cron jobs. It basically uses the [cronenberg](https://github.com/ess/cronenberg) binary with the jobs defined under `ky-specific/cronenberg/cron-jobs.yml`. Once the pod is up it will just run the jobs, like the standard cron does.

### migration
The `migration` process (the entry named `migration` in Procfile) is a little bit more complicated. The goal is to run the `db:migrate` command during deployments _before_ any other process starts. It aims to work like the one in EYCloud: the migration is executed _before_ the passenger/unicorn restart, so that the database schema will be there when the newly deployed code is executed. Like all commands in KontainerYard, the `db:migrate` should be executed in a pod. So, during a deployment the pod named `migration` will be started first, execute the "commands" and then (if successful) the rest of the pods will be started (e.g. `web`, `sidekiq`, `cronenberg`). In our example the "commands" is the script `ky-specific/migration/db-migrate.sh`. This shell script will actually invoke the command `db:migrate` and based on the result it will touch a file named `/tmp/migration-ready` within the pod.

As we have seen in the EYCloud deployments, if a `db:migrate` fails then the deployment is rolled back. We can achieve the same in KontainerYard via using the [readiness probe](https://docs.teamhephy.com/applications/managing-app-configuration/#custom-health-checks). The `readiness probe` is just an http or exec check in order to verify if a pod is in running. As mentioned above, the file `/tmp/migration-ready` will be created _once_ the migrations have finished successfully. If they fail for any reason then the file won't be created, thus the pod will be determined as failed, an exception will be thrown in the deis-controller side and the deployment will be rolled back.

The above show that a carefully chosen `readiness probe` is the key in order handle long running migrations. We have used successfully the following:

```
deis config set DEIS_DEPLOY_TIMEOUT=600 --app=ilias-ky-school

deis healthchecks:set readiness exec stat /tmp/migration-ready --type=migration --initial-delay=10 --period-seconds=10 --success-threshold=1 --failure-threshold=60 --app=ilias-ky-school

```
You may check for the details of the setting [DEIS_DEPLOY_TIMEOUT](https://docs.teamhephy.com/applications/deploying-apps/#tuning-application-settings)

### web
The web process will consist of one or more pods that will run the web server (in our case Puma).

### sidekiq
The web process will consist of one or more pods that will run the sidekiq workers.

# Autoscaling
In KontainerYard the notion of Autoscaling means different things according to the context. We have the following contexts:

* cluster
* pods
* custom

### cluster Autoscaling

This is a k8s component that controls the number of instances in the cluster. All the pods will run on the cluster's worker nodes (EC2 instances). When we start up more pods than the current cluster's capacity the  cluster autoscaler will signal AWS to add more nodes (instances). If the pods number drops, the cluster autoscaler will signal AWS to remove some nodes.


### pod Autoscaling

The Autoscaling in the KontainerYard case is actually the [](https://docs.teamhephy.com/applications/managing-app-processes/#autoscale)


# Run the code on KontainerYard


