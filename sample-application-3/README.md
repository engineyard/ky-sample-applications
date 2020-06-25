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

# About the code

The applicaton is basically the [rails_activejob_example](https://github.com/engineyard/rails_activejob_example) that we have been using for testing. 

The required resources for the original version of the `rails_activejob_example` application were database and redis in the case of sidekiq. In order to keep things simple we will pack in the **same container** (== the same pod in deis) all the required components:

* the database service (sqlite)
* the redis server

The configuration files that will need attantion are:

* `config/database.yml`
* `config/initializers/sidekiq.rb`

In the `config/database.yml` we just say that we want to use the sqlite database, while in `config/initializers/sidekiq.rb` we state which redis to use. In this simple example we could ommit the `config/initializers/sidekiq.rb` since as per the [sidekiq documentation](https://github.com/mperham/sidekiq/wiki/Using-Redis):
> By default, Sidekiq tries to connect to Redis at localhost:6379. This typically works great during development but needs tuning in production.

Another interesting point is the command that will start all the services. This is defined in the Dockerfile:

```
CMD redis-server --daemonize yes && bundle exec sidekiq --daemon && bundle exec rails server -b 0.0.0.0 -p 5000 -e development
```

Obviously we are trying to make a container behave like a virtual machine wehre all services run in one place. For this example it is ok, but further on we will split the services into multiple containers (pods).

# Run the code locally 

You may run the code locally using Docker. The commands would be:

```
docker build --tag example-application-2 .
docker run --rm -ti --name=persistent_harry -p 5000:5000 example-application-2
```
Then you may visit (the last url will add some jobs): 
http://localhost:5000
http://localhost:5000/sidekiq/
http://localhost:5000/enqueue-jobs/10

# Run the code on KontainerYard

The step by step procedure would be:

1. initialize your working directory:
```
ilias@ilias-LubuntuVM:[~/KontainerYard/JFPlayground/ky_school]: git init
```
2. Create the deis application:
```
ilias@ilias-LubuntuVM:[~/KontainerYard/JFPlayground/ky_school]: deis apps:create ilias-ky-school --remote=deis-ilias-ky-school
```
3. Make sure that the remote is correctly set: 
```
ilias@ilias-LubuntuVM:[~/KontainerYard/JFPlayground/ky_school]: git remote -v
deis-ilias-ky-school    ssh://git@deis-builder.jfuechsl-playground.kontaineryard.io:2222/ilias-ky-school.git (fetch)
deis-ilias-ky-school    ssh://git@deis-builder.jfuechsl-playground.kontaineryard.io:2222/ilias-ky-school.git (push)
```
4. Add your changes to git:
```
ilias@ilias-LubuntuVM:[~/KontainerYard/JFPlayground/ky_school]: git add -A
```
5. Commit you changes (locally):
```
ilias@ilias-LubuntuVM:[~/KontainerYard/JFPlayground/ky_school]: git commit -m "First commit" 
```
6. Deploy the application
```
ilias@ilias-LubuntuVM:[~/KontainerYard/JFPlayground/ky_school]: git push deis-ilias-ky-school master
```
7. View the details of the application after deployment 

```
deis info --app=ilias-ky-school
=== ilias-ky-school Application
updated:  2020-05-16T14:03:56Z
uuid:     ec4d1aae-5eac-48e2-bdfd-b7f50fccd0d0
created:  2020-05-16T09:49:28Z
url:      ilias-ky-school.jfuechsl-playground.kontaineryard.io
owner:    igiannoulas
id:       ilias-ky-school

=== ilias-ky-school Processes
--- web:
ilias-ky-school-web-7cc56554bd-8kzlz up (v2)

=== ilias-ky-school Domains
ilias-ky-school

=== ilias-ky-school Label
No labels found.
```

8. Visit the application in the urls (the last url will add some jobs): 

http://ilias-ky-school.jfuechsl-playground.kontaineryard.io/
http://ilias-ky-school.jfuechsl-playground.kontaineryard.io/sidekiq
http://ilias-ky-school.jfuechsl-playground.kontaineryard.io/enqueue-jobs/10






```

### KontainerYard usage of the application

Say that your KY application is named `ilias-simple-sidekiq-new`. In order to create some jobs you may use:

```
deis run "ECHO_JOB_COUNT=100 bundle exec rake echo:generate" --app=ilias-simple-sidekiq-new
deis run "COMPLEX_JOB_COUNT=150 bundle exec rake complex:generate" --app=ilias-simple-sidekiq-new
deis run "MEMCRASHER_JOB_COUNT=2 bundle exec rake memcrash:generate" --app=ilias-simple-sidekiq-new
deis run "CPUCRASHER_JOB_COUNT=2 bundle exec rake cpucrash:generate" --app=ilias-simple-sidekiq-new
```

where the `memcrash` and `cpucrash` jobs will create high memory and cpu usage.
