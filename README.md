# UD615: Scalable Microservices with Kubernetes

This is the code for [Scalable Microservices with Kubernetes](https://www.udacity.com/course/scalable-microservices-with-kubernetes--ud615).  In this course you will learn how to:

* Provision a complete Kubernetes using [Google Container Engine](https://cloud.google.com/container-engine)
* Deploy and manage Docker containers using kubectl

All of the code for this course was written by Kelsey Hightower.
Kubernetes Version: 1.2.2
Go Version: 1.6+

## Course Description

Kubernetes is all about applications and in this course you will utilize the Kubernetes API to deploy, manage, and upgrade applications. In this part of the workshop you will use an example application called "app" to complete the labs.

App is an example 12-Factor application that we'll be using throughout the course. During this course you will be working with the following Docker images:

* [askcarter/monolith](https://hub.docker.com/r/askcarter/monolith) - Monolith includes auth and hello services.
* [askcarter/auth](https://hub.docker.com/r/askcarter/auth) - Auth microservice. Generates JWT tokens for authenticated users.
* [askcarter/hello](https://hub.docker.com/r/askcarter/hello) - Hello microservice. Greets authenticated users.
* [ngnix](https://hub.docker.com/_/nginx) - Frontend to the auth and hello services.

## Links

  * [Kubernetes](http://googlecloudplatform.github.io/kubernetes)
  * [gcloud Tool Guide](https://cloud.google.com/sdk/gcloud)
  * [Docker](https://docs.docker.com)
  * [etcd](https://coreos.com/docs/distributed-configuration/getting-started-with-etcd)
  * [nginx](http://nginx.org)

## Demos

I've listed *all* of the steps from every demo during the talk so that you can run them yourself.  In the demo, I'll be doing everything in cloud shell.  And using Go version 1.6.  If you don't have version 1.6, install it.

### The First Hurdle:  The App

The first hurdle to getting online is the application itself.  How do you write it?  How do you deploy it?

First off let's set up the code and the go build environment
$ GOPATH=~/go
$ mkdir -p $GOPATH/src/github.com/askcarter
$ cd $GOPATH/src/github.com/askcarter
$ git clone https://github.com/askcarter/io16

Now let's build the app as a static binary and test it's functionality.
$ cd io16/app/monolith
$ go build -tags netgo -ldflags "-extldflags '-lm -lstdc++ -static'" .
$ ./monolith --http :10180 --health :10181 &
$ curl http://127.0.0.1:10180
$ curl http://127.0.0.1:10180/secure
$ curl http://127.0.0.1:10180/login -u user
$ curl http://127.0.0.1:10180/secure -H "Authorization: Bearer <token>"

Once we have a binary, we can use Docker to package and distribute it.
$ docker build -t askcarter/monolith:1.0.0 .
$ docker push askcarter/monolith:1.0.0
$ docker run -d askcarter/monolith:1.0.0
$ docker ps
$ docker inspect <cid>
$ curl http://<docker-ip>
$ docker rm <cid>
$ docker rmi askcarter/monolith:1.0.0

The next hurdle is the infrastructure needed to run manage in production.  We'll use Kubernetes (and GKE) to handle that for us.
$ cd ../../kubernetes
$ gcloud container clusters create io --num-nodes=6
$ kubectl run monolith --image askcarter/monolith:1.0.0
$ kubectl expose deployment monolith --port 80 --type LoadBalancer
$ kubectl get service monolith
$ curl http://<External-IP>
$ kubectl delete services monolith
# kubectl delete deployment monolith

Let's set up services and deployments for our microservices
$ kubectl create -f services/auth.yaml -f deployments/auth.yaml
$ kubectl create -f services/hello.yaml -f deployments/hello.yaml
$ kubectl create configmap nginx-frontend-conf --from-file nginx/frontend.conf
$ kubectl create secret generic tls-certs --from-file tls/
$ kubectl create -f services/frontend.yaml -f deployments/frontend.yaml
$ kubectl get services frontend
$ curl -k https://<External-IP>

The last hurdle is the The Wild.  How do we handle rolling out updates to our code?
$ sed -i s/hello:1.0.0/hello:2.0.0/g deployments/hello.yaml
$ kubectl apply -f deployments/hello.yaml
$ kubectl describe deployments hello

Cleanup
$ gcloud container clusters delete io

