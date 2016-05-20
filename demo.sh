#!/bin/bash

# Grab the frontends's External IP address using a template so I can curl it later.
IP=$(kubectl get svc frontend -o template --template "{{with index .status.loadBalancer.ingress 0}}{{.ip}}{{end}}")

while true
do
  curl -k https://$IP
  sleep .3
done

