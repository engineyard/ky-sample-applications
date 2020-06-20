# KontainerYard example-application-2: background_jobs

A minimalist Rails application created to test background workers on KY.

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





