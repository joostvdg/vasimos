echo "### ETCD Install script"

echo " ## Distribute local etcd install script to controllers"
for instance in controller-0 controller-1 controller-2; do
    echo " # Distributing to ${instance}"
    gcloud compute scp etcd-local.sh ${instance}:~/
done