# KontainerYard example-application-1

Simple GTD app for task tracking.

# About the code
The applicaton is basically the [todo application](https://github.com/engineyard/todo) that we have been using for testing. 
The required resources for the original version of the `todo` application were just a running database. Since this is meant to be a simple example on how to deploy applications, the database to be used will be just the sqlite. This means that the database is actually a file living in the pod, so no extra resources are needed. The details about this can be found under the `config/database.yml` file.

# Run the code locally 

You may run the code locally using Docker. The commands would be:

```
docker build --tag example-application-1 .
docker run --rm -ti --name=persistent_harry -p 5000:5000 example-application-1
```
Then you may visit http://localhost:5000 in order to use the application.

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

8. Visit the application in the url: http://ilias-ky-school.jfuechsl-playground.kontaineryard.io/
