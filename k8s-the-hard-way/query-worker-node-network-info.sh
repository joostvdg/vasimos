echo "Querying network information for worker nodes"
echo "|Node Internal IP | Pod CIDR | "

for instance in worker-0 worker-1 worker-2; do
  echo "Querying instance: ${instance}"
  gcloud compute instances describe ${instance} \
    --format 'value[separator=" "](networkInterfaces[0].networkIP,metadata.items[0].value)'
done

echo "Querying network routes for worker nodes"
gcloud compute routes list --filter "network: kubernetes-the-hard-way"
