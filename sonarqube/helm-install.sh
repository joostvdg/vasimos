# You might need to override this, for example in Minikube or GKE installs
SERVICE_TYPE=${1:-"ClusterIP"}
NAMESPACE=${2:-"default"}
VERSION=${3:-"6.7.5"}
NAME=${4:-"sonar"}

echo "#######################################"
echo "### Doing helm install for SonarQube"
echo "# SERVICE_TYPE=${SERVICE_TYPE}"
echo "# NAMESPACE=${NAMESPACE}"
echo "# VERSION=${VERSION}"
echo "# NAME=${NAME}"

helm install --name ${NAME} \
    --namespace ${NAMESPACE} \
    --set persistence.enabled="true" \
    --set persistence.accessMode="ReadWriteOnce" \
    --set persistence.size="2G" \
    --set image.tag=${VERSION} \
    --set service.type=${SERVICE_TYPE} \
    stable/sonarqube

kubectl delete ing sonarqube-sonarqube -m ${NAMESPACE}
kubectl apply -f sonarqube-helm-ingress.yml