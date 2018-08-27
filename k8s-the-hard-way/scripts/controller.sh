echo "### Controller Install script"

echo " ## Distribute local controller install script to controllers"
for instance in controller-0 controller-1 controller-2; do
    echo " # Distributing to ${instance}"
    gcloud compute scp controller-local.sh ${instance}:~/
done