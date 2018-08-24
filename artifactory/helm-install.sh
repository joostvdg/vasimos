helm install --name artifactory --namespace vasimos \
    --set ingress.enabled="true" \
    --set ingress.hosts="{artifactory.127.0.0.1.nip.io}" \
    --set artifactory.image.repository=docker.bintray.io/jfrog/artifactory-oss \
    --set artifactory.resources.requests.cpu="100m" \
    --set artifactory.resources.limits.cpu="100m" \
    --set artifactory.resources.requests.memory="512Mi" \
    --set artifactory.resources.limits.memory="512Mi" \
    --set artifactory.javaOpts.xms="512m" \
    --set artifactory.javaOpts.xmx="512m" \
    --set nginx.resources.requests.cpu="100m" \
    --set nginx.resources.limits.cpu="100m" \
    --set nginx.resources.requests.memory="50Mi" \
    --set nginx.resources.limits.memory="50Mi" \
 stable/artifactory
