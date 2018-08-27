echo "### WORKER Install script"

echo " ## Distribute local worker install script to workers"
for instance in worker-0 worker-1 worker-2; do
    echo " # Distributing to ${instance}"
    gcloud compute scp worker-local.sh ${instance}:~/
done