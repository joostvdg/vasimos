# vasimos

vásimos or βάσιμος is a CI stack for kubernetes

## Jenkins On Kubernetes

* https://blog.kublr.com/using-jenkins-and-kubernetes-for-continuous-integration-and-delivery-4e4341aff013
* http://blog.xebia.com/kubernetes-ci-builders/
* https://github.com/jenkinsci/kubernetes-plugin
* https://radu-matei.com/blog/kubernetes-jenkins-azure/
* https://www.infoq.com/articles/scaling-docker-with-kubernetes
* https://github.com/jenkinsci/kubernetes-pipeline-plugin
* https://github.com/hoshsadiq/jenkins-kubernetes-secrets-credentials

### Manual

* Persistent storage
* Jenkins master
    * Deployment
    * Service
    * Ingress (8080, 50000)
* Agent
    * ?

### Via Helm

```bash
helm install --name jenkins -f jenkins/jenkins-helm.yml stable/jenkins
```

```bash
helm del --purge jenkins
```

The Helm chart overrides all the properties and configurations in your image though.

So I would NOT recommend using it - build once run anywhere is void if everything is configurable/overidden.